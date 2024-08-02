---
to: src/app/login/page.tsx
---

"use client";
import LoginWithEmail from "@/components/auth/LoginWithEmail";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { useAuth } from "src/hooks/useAuth";

const Login = () => {
  const [showLogin, toggleShowLogin] = useState(false);
  const { isLoading, isAuthenticated } = useAuth();
  const router = useRouter();
  const goToHome = useCallback(() => router.push("/home"), [router]);
  useEffect(() => {
    if (isLoading) {
      return;
    } else if (isAuthenticated) {
      // const urlParams = new URLSearchParams(window.location.search);
      // const myParam = urlParams.get('redirect');
      // if (myParam) {
      //   window.location.href = decodeURIComponent(myParam || "/")
      // } else {
      //   goToHome();
      // }
      goToHome();
    } else {
      toggleShowLogin(true);
    }
  }, [isAuthenticated, isLoading, goToHome]);

  return <>{showLogin && <LoginWithEmail />}</>;
};

export default Login;
