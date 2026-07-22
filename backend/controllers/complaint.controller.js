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

        await prisma.notification.create({
            data: {
                userId: req.user.id,
                complaintId: complaint.id,
                type: "COMPLAINT_SUBMITTED",
                title: "Complaint submitted",
                message: `Your ${category || "complaint"} at ${village} was registered successfully.`,
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

const STATUS_NOTIFICATIONS = {
    IN_PROGRESS: {
        type: "COMPLAINT_ASSIGNED",
        title: "Complaint assigned",
        message: (complaint, officerName) =>
            `Your ${complaint.category || "complaint"} at ${complaint.village} was assigned to ${officerName || "an officer"}.`,
    },
    RESOLVED: {
        type: "COMPLAINT_RESOLVED",
        title: "Complaint resolved",
        message: (complaint) =>
            `Your ${complaint.category || "complaint"} at ${complaint.village} has been resolved.`,
    },
    REJECTED: {
        type: "COMPLAINT_REJECTED",
        title: "Complaint rejected",
        message: (complaint, _officerName, reason) =>
            reason || `Your ${complaint.category || "complaint"} at ${complaint.village} was rejected.`,
    },
};

export const updateComplaintStatus = async(req, res) => {
    try {
        const { id } = req.params;
        const { status, reason } = req.body;

        const notificationSpec = STATUS_NOTIFICATIONS[status];
        if (!notificationSpec) {
            return res.status(400).json({
                success: false,
                message: "Status must be one of IN_PROGRESS, RESOLVED, REJECTED",
            });
        }

        const complaint = await prisma.complaint.findUnique({ where: { id } });
        if (!complaint) {
            return res.status(404).json({
                success: false,
                message: "Complaint not found",
            });
        }

        const officer = await prisma.user.findUnique({ where: { id: req.user.id } });

        const updated = await prisma.complaint.update({
            where: { id },
            data: {
                status,
                officer: officer?.name || complaint.officer,
            },
        });

        await prisma.notification.create({
            data: {
                userId: complaint.userId,
                complaintId: complaint.id,
                type: notificationSpec.type,
                title: notificationSpec.title,
                message: notificationSpec.message(complaint, officer?.name, reason),
            },
        });

        return res.status(200).json({
            success: true,
            message: "Complaint status updated",
            complaint: updated,
        });
    } catch (error) {
        console.error("Update complaint status error:", error);
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
