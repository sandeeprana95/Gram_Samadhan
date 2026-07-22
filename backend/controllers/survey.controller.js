import prisma from "../config/prisma.js";

const VALID_CONDITIONS = ["GOOD", "FAIR", "POOR", "DAMAGED"];

export const createSurvey = async(req, res) => {
    try {
        const {
            assetTypeId,
            assetName,
            district,
            panchayat,
            village,
            latitude,
            longitude,
            description,
            condition,
            surveyDate,
        } = req.body;

        if (!assetTypeId || !assetName || !district || !panchayat || !village) {
            return res.status(400).json({
                success: false,
                message: "Asset type, asset name, district, panchayat and village are required",
            });
        }

        const normalizedCondition = String(condition || "").toUpperCase();
        if (!VALID_CONDITIONS.includes(normalizedCondition)) {
            return res.status(400).json({
                success: false,
                message: "Condition must be one of Good, Fair, Poor, Damaged",
            });
        }

        const files = req.files || [];
        if (files.length === 0) {
            return res.status(400).json({
                success: false,
                message: "At least one photo is required",
            });
        }

        const photoUrls = files.map((file) => `/uploads/surveys/${file.filename}`);

        const survey = await prisma.$transaction(async(tx) => {
            const counter = await tx.counter.upsert({
                where: { name: "asset_id" },
                create: { name: "asset_id", value: 1 },
                update: { value: { increment: 1 } },
            });
            const assetId = `AST${String(counter.value).padStart(6, "0")}`;

            return tx.survey.create({
                data: {
                    assetId,
                    assetTypeId,
                    assetName,
                    district,
                    panchayat,
                    village,
                    latitude: latitude != null && latitude !== "" ? Number(latitude) : null,
                    longitude: longitude != null && longitude !== "" ? Number(longitude) : null,
                    photoUrls,
                    description: description?.trim() || null,
                    condition: normalizedCondition,
                    surveyDate: surveyDate ? new Date(surveyDate) : new Date(),
                    surveyedById: req.user.id,
                },
            });
        });

        return res.status(201).json({
            success: true,
            message: "Survey submitted successfully",
            survey,
        });
    } catch (error) {
        console.error("Create survey error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};

export const getMySurveys = async(req, res) => {
    try {
        const surveys = await prisma.survey.findMany({
            where: { surveyedById: req.user.id },
            orderBy: { createdAt: "desc" },
        });

        return res.status(200).json({
            success: true,
            surveys,
        });
    } catch (error) {
        console.error("List surveys error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};

export const getSurveyById = async(req, res) => {
    try {
        const { id } = req.params;

        const survey = await prisma.survey.findUnique({ where: { id } });

        if (!survey || survey.surveyedById !== req.user.id) {
            return res.status(404).json({
                success: false,
                message: "Survey not found",
            });
        }

        return res.status(200).json({
            success: true,
            survey,
        });
    } catch (error) {
        console.error("Get survey error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};
