import express from "express";
import {
    createComplaint,
    getMyComplaints,
    getComplaintById,
} from "../controllers/complaint.controller.js";
import { requireAuth } from "../middleware/auth.middleware.js";
import { uploadComplaintPhoto } from "../middleware/upload.middleware.js";

const router = express.Router();

router.post(
    "/",
    requireAuth,
    (req, res, next) => {
        uploadComplaintPhoto(req, res, (err) => {
            if (err) {
                return res.status(400).json({
                    success: false,
                    message: err.message || "Photo upload failed",
                });
            }
            next();
        });
    },
    createComplaint
);

router.get("/", requireAuth, getMyComplaints);
router.get("/:id", requireAuth, getComplaintById);

export default router;
