import express from "express";
import { sendOtp, resendOtp, verifyOtp, getMe, staffLogin } from "../controllers/auth.controller.js";
import { requireAuth } from "../middleware/auth.middleware.js";

const router = express.Router()

router.post("/send-otp", sendOtp)
router.post("/resend-otp", resendOtp)
router.post("/verify-otp", verifyOtp)
router.post("/staff-login", staffLogin)
router.get("/me", requireAuth, getMe)

export default router;
