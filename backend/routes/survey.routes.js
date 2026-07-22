import express from "express";
import {
    createSurvey,
    getMySurveys,
    getSurveyById,
} from "../controllers/survey.controller.js";
import { requireAuth } from "../middleware/auth.middleware.js";
import { requireRole } from "../middleware/role.middleware.js";
import { uploadSurveyPhotos } from "../middleware/upload.middleware.js";

const router = express.Router();

router.post(
    "/",
    requireAuth,
    requireRole("SURVEYOR"),
    (req, res, next) => {
        uploadSurveyPhotos(req, res, (err) => {
            if (err) {
                return res.status(400).json({
                    success: false,
                    message: err.message || "Photo upload failed",
                });
            }
            next();
        });
    },
    createSurvey
);

router.get("/", requireAuth, requireRole("SURVEYOR"), getMySurveys);
router.get("/:id", requireAuth, requireRole("SURVEYOR"), getSurveyById);

export default router;
