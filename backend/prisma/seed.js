import bcrypt from "bcryptjs";
import prisma from "../config/prisma.js";

const demoStaff = [
    { staffId: "officer", password: "Officer@123", name: "Officer Ramesh Kumar", role: "OFFICER" },
    { staffId: "survey", password: "Survey@123", name: "Priya Sharma", role: "SURVEYOR" },
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
}

main()
    .catch((error) => {
        console.error("Seed failed:", error);
        process.exitCode = 1;
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
