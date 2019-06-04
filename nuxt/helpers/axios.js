const specificHeaders = {
  singleObject: { Accept: 'application/vnd.pgrst.object+json' },
  preferExactCount: { Prefer: 'count=exact' },
  preferRepresentation: { Prefer: 'return=representation' },
};

// Content-Range: 0-24/3573458
// -> { start: 0, finish: 24, total: 3573458 }
const extractRange = range => {
  const rangeData = range.replace('-', '/').split('/');
  rangeData[0] = parseInt(rangeData[0]);
  rangeData[1] = parseInt(rangeData[1]);
  if (rangeData.length < 3 || rangeData[2] === '*') {
    rangeData[2] = -1;
  } else {
    rangeData[2] = parseInt(rangeData[2]);
  }
  const [start, finish, total] = rangeData;
  return { start, finish, total };
};

const extractData = (result, defaultMeta = {}) => {
  const items = result.data;
  const meta = {
    ...defaultMeta,
    ...extractRange(result.headers['content-range']),
  };
  return { meta, items };
};

const simpleRequest = async promise => {
  try {
    const result = await promise;
    return { ...result, status: 'success' };
  } catch (error) {
    return { error, status: 'error' };
  }
};

const metaRequest = async (promise, { limit, offset }) => {
  try {
    const response = await promise;

    const result = extractData(response, {
      limit,
      offset,
    });

    return { ...result, status: 'success' };
  } catch (error) {
    return { error, status: 'error' };
  }
};

export const rpc = ($axios, endpoint, complexParams = {}) => {
  const { config = {}, data = {}, single = false, represent = false } = complexParams;

  return simpleRequest(
    $axios.$post(endpoint, data, {
      ...config,
      headers: {
        ...(single ? specificHeaders.singleObject : {}),
        ...(represent ? specificHeaders.preferRepresentation : {}),
      },
    }),
  );
};

export const getOne = ($axios, endpoint, config = {}) => {
  return simpleRequest(
    $axios.$get(endpoint, {
      ...config,
      headers: {
        ...specificHeaders.singleObject,
      },
    }),
  );
};

export const getAll = ($axios, endpoint, config = {}) => {
  const { params = {} } = config;

  return metaRequest(
    $axios.get(endpoint, {
      ...config,
      headers: {
        ...specificHeaders.preferExactCount,
      },
    }),
    params,
  );
};

export const add = ($axios, endpoint, complexParams = {}) => {
  const { config = {}, data = {}, single = false, represent = false } = complexParams;

  return simpleRequest(
    $axios.$post(endpoint, data, {
      ...config,
      headers: {
        ...(single ? specificHeaders.singleObject : {}),
        ...(represent ? specificHeaders.preferRepresentation : {}),
      },
    }),
  );
};

export const mark = ($axios, endpoint, complexParams = {}) => {
  const { config = {}, data = {} } = complexParams;
  const { params = {} } = config;

  if (Object.keys(params).length === 0) {
    throw new Error('Patch requests without any condition are forbidden');
  }

  return simpleRequest($axios.$patch(endpoint, data, config));
};

export const del = ($axios, endpoint, config = {}) => {
  const { params = {} } = config;

  if (Object.keys(params).length === 0) {
    throw new Error('Delete requests without any condition are forbidden');
  }

  return simpleRequest($axios.$delete(endpoint, config));
};
