---
to: src/components/auth/LoginWithEmail.tsx
---


import { useCallback, useState } from "react";
import TextInput from "../core/Input";
import Button from "../core/Button";
import { useAuth } from "@/hooks/useAuth";
import { cookies } from "@/utils/cookie";

const LoginWithEmail = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const { updateToken } = useAuth();

  const loginUser = useCallback(() => {
    updateToken("my-token");
    cookies.set("serviceOrgId", 23);
  }, [updateToken]);
  return (
    <div className="w-full h-screen flex items-center justify-center flex-col">
      <div className="w-[20rem] flex gap-4 flex-col">
        <div className="flex flex-col gap-1">
          <div>Email</div>
          <TextInput
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="john@doe.com"
          />
        </div>
        <div className="flex flex-col gap-1 mb-3">
          <div>Password</div>
          <TextInput
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Password"
          />
        </div>
        <Button onClick={loginUser}>Login</Button>
      </div>
    </div>
  );
};

export default LoginWithEmail;
