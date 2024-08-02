type TextInputType = {
  value: string | undefined;
  onChange?: (event: React.ChangeEvent<HTMLInputElement>) => void;
  onFocus?: (event: React.ChangeEvent<HTMLInputElement>) => void;
  onBlur?: (event: React.ChangeEvent<HTMLInputElement>) => void;
  placeholder?: string;
};

const TextInput: React.FC<TextInputType> = ({
  value,
  onChange,
  placeholder,
  onBlur,
  onFocus,
}) => {
  return (
    <input
      value={value}
      onChange={onChange}
      placeholder={placeholder}
      onBlur={onBlur}
      onFocus={onFocus}
      className="border py-1 px-2 rounded-md"
    />
  );
};

export default TextInput;
