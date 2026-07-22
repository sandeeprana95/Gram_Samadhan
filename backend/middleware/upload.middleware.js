import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import multer from "multer";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const uploadDir = path.join(__dirname, "..", "uploads", "complaints");
fs.mkdirSync(uploadDir, { recursive: true });

const surveyUploadDir = path.join(__dirname, "..", "uploads", "surveys");
fs.mkdirSync(surveyUploadDir, { recursive: true });

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadDir),
    filename: (req, file, cb) => {
        const ext = path.extname(file.originalname) || ".jpg";
        cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
    },
});

const surveyStorage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, surveyUploadDir),
    filename: (req, file, cb) => {
        const ext = path.extname(file.originalname) || ".jpg";
        cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
    },
});

const fileFilter = (req, file, cb) => {
    if (!file.mimetype.startsWith("image/")) {
        return cb(new Error("Only image files are allowed"));
    }
    cb(null, true);
};

export const uploadComplaintPhoto = multer({
    storage,
    fileFilter,
    limits: { fileSize: 8 * 1024 * 1024 },
}).single("photo");

export const uploadSurveyPhotos = multer({
    storage: surveyStorage,
    fileFilter,
    limits: { fileSize: 8 * 1024 * 1024, files: 5 },
}).array("photos", 5);
