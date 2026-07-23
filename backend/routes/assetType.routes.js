import express from "express";
import { listAssetTypes } from "../controllers/assetType.controller.js";
import { requireAuth } from "../middleware/auth.middleware.js";

const router = express.Router();

router.get("/", requireAuth, listAssetTypes);

export default router;
