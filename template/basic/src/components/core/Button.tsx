import { ReactNode } from "react";

type ButtonType = {
  children: ReactNode;
  onClick: (event: React.MouseEvent<HTMLButtonElement, MouseEvent>) => void;
};

const Button: React.FC<ButtonType> = ({ children, onClick }) => {
  return (
    <button onClick={onClick} className="bg-black text-white rounded-md p-1">
      {children}
    </button>
  );
};

export default Button;
