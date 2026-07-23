import bcrypt from "bcryptjs";
import prisma from "../config/prisma.js";

const demoStaff = [
    { staffId: "officer", password: "Officer@123", name: "Officer Ramesh Kumar", role: "OFFICER" },
    { staffId: "survey", password: "Survey@123", name: "Priya Sharma", role: "SURVEYOR" },
];

// Mirrors frontend/lib/data/asset_types_data.dart — the catalog now lives in
// the database so new asset types can be added without an app release.
const assetTypes = [
    { id: "ast_01", name: "Govt. Primary School", iconKey: "school" },
    { id: "ast_02", name: "Govt. High School", iconKey: "school" },
    { id: "ast_03", name: "Govt. Sr. Sec. School", iconKey: "school" },
    { id: "ast_04", name: "Anganwadi Center", iconKey: "child_care" },
    { id: "ast_05", name: "Community Health Center", iconKey: "local_hospital" },
    { id: "ast_06", name: "Public Health Center", iconKey: "medical_services" },
    { id: "ast_07", name: "Veterinary Hospital", iconKey: "pets" },
    { id: "ast_08", name: "Panchayat Ghar", iconKey: "account_balance" },
    { id: "ast_09", name: "Community Center", iconKey: "groups" },
    { id: "ast_10", name: "Women Chaupal", iconKey: "woman" },
    { id: "ast_11", name: "SC Chaupal", iconKey: "diversity_3" },
    { id: "ast_12", name: "BC Chaupal", iconKey: "diversity_3" },
    { id: "ast_13", name: "General Chaupal", iconKey: "forum" },
    { id: "ast_14", name: "Sports Stadium", iconKey: "stadium" },
    { id: "ast_15", name: "Gymnasium", iconKey: "fitness_center" },
    { id: "ast_16", name: "Park cum Vyayamshala", iconKey: "park" },
    { id: "ast_17", name: "Religious Place", iconKey: "temple_hindu" },
    { id: "ast_18", name: "Shamshan Ghat", iconKey: "local_fire_department" },
    { id: "ast_19", name: "Kabristan", iconKey: "church" },
    { id: "ast_20", name: "Zila Parishad Building", iconKey: "domain" },
    { id: "ast_21", name: "Block Office Building", iconKey: "business" },
    { id: "ast_22", name: "Patwar Bhawan", iconKey: "home_work" },
    { id: "ast_23", name: "Tubewell", iconKey: "water_drop" },
    { id: "ast_24", name: "Post Office", iconKey: "local_post_office" },
    { id: "ast_25", name: "Street Network", iconKey: "alt_route" },
    { id: "ast_26", name: "Open Space", iconKey: "landscape" },
    { id: "ast_27", name: "Bus Queue Shelter", iconKey: "directions_bus" },
    { id: "ast_28", name: "Solar Light Pole", iconKey: "wb_sunny" },
    { id: "ast_29", name: "Library", iconKey: "local_library" },
    { id: "ast_30", name: "Rajiv Gandhi Seva Kendra", iconKey: "handshake" },
    { id: "ast_31", name: "Gram Sachivalaya", iconKey: "gavel" },
    { id: "ast_32", name: "Mahila Sanskriti Kendra", iconKey: "spa" },
    { id: "ast_33", name: "Old Age Home", iconKey: "elderly" },
    { id: "ast_34", name: "Amrit Sarovar", iconKey: "water_drop" },
];

async function main() {
    for (const staff of demoStaff) {
        const passwordHash = await bcrypt.hash(staff.password, 10);
        await prisma.user.upsert({
            where: { staffId: staff.staffId },
            create: {
                staffId: staff.staffId,
                passwordHash,
                name: staff.name,
                role: staff.role,
            },
            update: {
                passwordHash,
                name: staff.name,
                role: staff.role,
            },
        });
        console.log(`Seeded ${staff.role} account: staffId=${staff.staffId} password=${staff.password}`);
    }

    for (let i = 0; i < assetTypes.length; i++) {
        const { id, name, iconKey } = assetTypes[i];
        await prisma.assetType.upsert({
            where: { id },
            create: { id, name, iconKey, sortOrder: i },
            update: { name, iconKey, sortOrder: i },
        });
    }
    console.log(`Seeded ${assetTypes.length} asset types`);
}

main()
    .catch((error) => {
        console.error("Seed failed:", error);
        process.exitCode = 1;
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
