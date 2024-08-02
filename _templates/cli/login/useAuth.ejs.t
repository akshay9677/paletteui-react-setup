---
to: <%= component %>/src/hooks/useAuth.tsx
overwrite: true
---
"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import { cookies } from "../utils/cookie";
import { isEmpty } from "../utils/validation";
import { useRouter } from "next/navigation";

type AuthContextType = {
  isLoading: boolean;
  isAuthenticated: boolean;
  error?: string;
  updateToken: (token: string) => void;
  updateError: (token: string) => void;
};

export const AuthContext = createContext<AuthContextType>(
  {} as AuthContextType
);

const useProvideAuth = () => {
  const [isLoading, setLoading] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [error, setError] = useState("");
  const router = useRouter();

  useEffect(() => {
    setLoading(true);
    let value = cookies.get("authtoken");
    let orgid = cookies.get("serviceOrgId");
    if (!isEmpty(value) && !isEmpty(orgid)) {
      setIsAuthenticated(true);
      setError("");
    } else {
      setIsAuthenticated(false);
      setError("Unauthenticated Page");
      router.push("/login");
    }
    setLoading(false);
  }, [router]);

  const updateToken = useCallback((authToken: string) => {
    setIsAuthenticated(true);
    setError("");
    var now = new Date();
    var time = now.getTime();
    var expireTime = time + 1000 * 604800;
    now.setTime(expireTime);
    document.cookie =
      "authtoken=" +
      authToken +
      `;domain=.mellow.team;path=/;expires=${now.toUTCString()}`;
    if (window.location.hostname.includes("localhost")) {
      cookies.set("authtoken", authToken);
    }
  }, []);

  const updateError = useCallback((error: string) => {
    setError(error);
    setIsAuthenticated(false);
  }, []);
  return { isLoading, isAuthenticated, error, updateToken, updateError };
};

export const AuthProvider = ({
  children,
}: {
  children: React.ReactElement[] | React.ReactElement;
}) => {
  const auth = useProvideAuth();

  return useMemo(
    () => <AuthContext.Provider value={auth}>{children}</AuthContext.Provider>,
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [auth.isAuthenticated, auth.isLoading, auth.error, children]
  );
};

export const useAuth = () => {
  return useContext(AuthContext);
};
