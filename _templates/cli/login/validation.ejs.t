---
to: <%= component %>/src/utils/validation.ts
overwrite: true
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

export const isSameDay = (firstDate: Date, secondDate: Date) => {
  return (
    firstDate.getFullYear() == secondDate.getFullYear() &&
    firstDate.getMonth() == secondDate.getMonth() &&
    firstDate.getDate() == secondDate.getDate()
  );
};

