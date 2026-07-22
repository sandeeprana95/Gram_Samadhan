import prisma from "../config/prisma.js";

export const getMyNotifications = async(req, res) => {
    try {
        const notifications = await prisma.notification.findMany({
            where: { userId: req.user.id },
            orderBy: { createdAt: "desc" },
        });

        return res.status(200).json({
            success: true,
            notifications,
        });
    } catch (error) {
        console.error("List notifications error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};

export const markNotificationRead = async(req, res) => {
    try {
        const { id } = req.params;

        const notification = await prisma.notification.findUnique({ where: { id } });

        if (!notification || notification.userId !== req.user.id) {
            return res.status(404).json({
                success: false,
                message: "Notification not found",
            });
        }

        const updated = await prisma.notification.update({
            where: { id },
            data: { isRead: true },
        });

        return res.status(200).json({
            success: true,
            notification: updated,
        });
    } catch (error) {
        console.error("Mark notification read error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};
