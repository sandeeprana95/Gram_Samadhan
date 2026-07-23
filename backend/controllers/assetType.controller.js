import prisma from "../config/prisma.js";

export const listAssetTypes = async(req, res) => {
    try {
        const assetTypes = await prisma.assetType.findMany({
            orderBy: { sortOrder: "asc" },
        });

        return res.status(200).json({ success: true, assetTypes });
    } catch (error) {
        console.error("List asset types error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};
