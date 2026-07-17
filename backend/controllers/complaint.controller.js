import prisma from "../config/prisma.js";

export const createComplaint = async(req, res) => {
    try {
        const {
            assetTypeId,
            assetInstanceId,
            category,
            village,
            panchayat,
            description,
            latitude,
            longitude,
        } = req.body;

        if (!village || !panchayat) {
            return res.status(400).json({
                success: false,
                message: "Village and panchayat are required",
            });
        }

        const photoUrl = req.file
            ? `/uploads/complaints/${req.file.filename}`
            : null;

        const complaint = await prisma.complaint.create({
            data: {
                userId: req.user.id,
                assetTypeId: assetTypeId || null,
                assetInstanceId: assetInstanceId || null,
                category: category || null,
                village,
                panchayat,
                description: description?.trim() || "Complaint registered from mobile app.",
                photoUrl,
                latitude: latitude != null ? Number(latitude) : null,
                longitude: longitude != null ? Number(longitude) : null,
            },
        });

        return res.status(201).json({
            success: true,
            message: "Complaint submitted successfully",
            complaint,
        });
    } catch (error) {
        console.error("Create complaint error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};

export const getMyComplaints = async(req, res) => {
    try {
        const complaints = await prisma.complaint.findMany({
            where: { userId: req.user.id },
            orderBy: { createdAt: "desc" },
        });

        return res.status(200).json({
            success: true,
            complaints,
        });
    } catch (error) {
        console.error("List complaints error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};

export const getComplaintById = async(req, res) => {
    try {
        const { id } = req.params;

        const complaint = await prisma.complaint.findUnique({ where: { id } });

        if (!complaint || complaint.userId !== req.user.id) {
            return res.status(404).json({
                success: false,
                message: "Complaint not found",
            });
        }

        return res.status(200).json({
            success: true,
            complaint,
        });
    } catch (error) {
        console.error("Get complaint error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};
