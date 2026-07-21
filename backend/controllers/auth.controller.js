import { randomInt } from "crypto";
import axios from "axios";
import jwt from "jsonwebtoken";
import prisma from "../config/prisma.js";

const MOBILE_PATTERN = /^[6-9]\d{9}$/;
const OTP_TTL_MS = 2 * 60 * 1000;
// Lets QA/reviewers sign in without a real SMS OTP; verifyOtp accepts any OTP for this number.
const TEST_MOBILE = "9999999999";
const SMS_GATEWAY_URL = "https://sms.pixabits.in/smsapi/sms/custom/send";

const normalizeMobile = (mobile) => {
    if (!mobile) return null;
    const digitsOnly = String(mobile).replace(/\D/g, "").replace(/^91(?=\d{10}$)/, "");
    return MOBILE_PATTERN.test(digitsOnly) ? digitsOnly : null;
};

// Must match the DLT-registered template text for SMS_TEMP_DLT_ID exactly
// (only the OTP variable may change) or the carrier silently drops the SMS
// even though the gateway API reports success.
const buildOtpMessage = (otp) =>
    `Your One Time Password is ${otp} for your application. Don't share OTP with anyone.HARSAC`;

const sendOtpSms = async(mobile, otp) => {
    if (!process.env.SMS_API_KEY) {
        console.warn("SMS_API_KEY not configured - skipping real SMS send");
        return false;
    }

    await axios.post(SMS_GATEWAY_URL, {
        key: process.env.SMS_API_KEY,
        text: buildOtpMessage(otp),
        senderId: process.env.SMS_SENDER_ID,
        tempDltId: process.env.SMS_TEMP_DLT_ID,
        route: "Domestic",
        phoneno: mobile,
        groupIds: [" "],
        trans: 1,
        unicode: 0,
        flash: false,
        tiny: false,
    });
    return true;
};

const issueOtp = async(mobile) => {
    const otp = randomInt(1000, 10000).toString();
    const expiresAt = new Date(Date.now() + OTP_TTL_MS);

    await prisma.otp.deleteMany({ where: { mobile } });
    await prisma.otp.create({ data: { mobile, otp, expiresAt } });

    if (process.env.NODE_ENV !== "production") {
        console.log(`[DEV ONLY] OTP for ${mobile}: ${otp}`);
    }

    let smsSent = false;
    let warning;
    try {
        smsSent = await sendOtpSms(mobile, otp);
    } catch (smsError) {
        console.error("SMS gateway error:", smsError.message);
        warning = "OTP generated but SMS delivery failed. Please try resending.";
    }

    return { smsSent, warning };
};

// ===================== SEND OTP =====================
export const sendOtp = async(req, res) => {
    try {
        const mobile = normalizeMobile(req.body.mobile);

        if (!mobile) {
            return res.status(400).json({
                success: false,
                message: "Enter a valid 10-digit mobile number",
            });
        }

        const { smsSent, warning } = await issueOtp(mobile);

        return res.status(200).json({
            success: true,
            message: smsSent ? "OTP sent successfully" : "OTP generated",
            smsSent,
            expiresIn: "2 minutes",
            ...(warning ? { warning } : {}),
        });
    } catch (error) {
        console.error("Send OTP error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};

// ===================== RESEND OTP =====================
export const resendOtp = async(req, res) => {
    try {
        const mobile = normalizeMobile(req.body.mobile);

        if (!mobile) {
            return res.status(400).json({
                success: false,
                message: "Enter a valid 10-digit mobile number",
            });
        }

        const { smsSent, warning } = await issueOtp(mobile);

        return res.status(200).json({
            success: true,
            message: smsSent ? "OTP resent successfully" : "OTP generated",
            smsSent,
            expiresIn: "2 minutes",
            ...(warning ? { warning } : {}),
        });
    } catch (error) {
        console.error("Resend OTP error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};

// ===================== VERIFY OTP + LOGIN =====================
export const verifyOtp = async(req, res) => {
    try {
        const mobile = normalizeMobile(req.body.mobile);
        const { otp } = req.body;

        if (!mobile || !otp) {
            return res.status(400).json({
                success: false,
                message: "Mobile number and OTP are required",
            });
        }

        if (mobile !== TEST_MOBILE) {
            const record = await prisma.otp.findFirst({
                where: { mobile, otp: String(otp) },
                orderBy: { createdAt: "desc" },
            });

            if (!record) {
                return res.status(400).json({ success: false, message: "Invalid OTP" });
            }

            if (record.expiresAt < new Date()) {
                await prisma.otp.deleteMany({ where: { mobile } });
                return res.status(400).json({ success: false, message: "OTP expired" });
            }
        }

        await prisma.otp.deleteMany({ where: { mobile } });

        const user = await prisma.user.upsert({
            where: { mobile },
            update: {},
            create: { mobile },
        });

        const token = jwt.sign(
            { id: user.id, mobile: user.mobile },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || "1d" }
        );

        return res.status(200).json({
            success: true,
            message: "OTP verified successfully",
            token,
            user: { id: user.id, mobile: user.mobile },
        });
    } catch (error) {
        console.error("Verify OTP error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};

// ===================== CURRENT USER =====================
export const getMe = async(req, res) => {
    return res.status(200).json({ success: true, user: req.user });
};
