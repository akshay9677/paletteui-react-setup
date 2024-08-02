---
to: src/utils/validation.ts
force: true
---
export const isEmpty = (value: any) => {
  return (
    value === undefined ||
    value === null ||
    Number(value) === -1 ||
    (typeof value === "object" && Object.keys(value).length === 0) ||
    (typeof value === "string" && value.trim().length === 0)
  );
};

export const isFunction = (value: any) => {
  return typeof value === "function";
};
