export const lastPageCriteria = ({ limit, total }) => {
  const offset = Math.max(0, Math.floor(total / limit) * limit);
  return { limit, offset };
};
