-- CreateEnum
CREATE TYPE "Role" AS ENUM ('CITIZEN', 'OFFICER', 'ADMIN');

-- CreateEnum
CREATE TYPE "SurveyCondition" AS ENUM ('GOOD', 'FAIR', 'POOR', 'DAMAGED');

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "name" TEXT,
ADD COLUMN     "passwordHash" TEXT,
ADD COLUMN     "role" "Role" NOT NULL DEFAULT 'CITIZEN',
ADD COLUMN     "staffId" TEXT,
ALTER COLUMN "mobile" DROP NOT NULL;

-- CreateTable
CREATE TABLE "Counter" (
    "name" TEXT NOT NULL,
    "value" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "Counter_pkey" PRIMARY KEY ("name")
);

-- CreateTable
CREATE TABLE "Survey" (
    "id" TEXT NOT NULL,
    "assetId" TEXT NOT NULL,
    "assetTypeId" TEXT NOT NULL,
    "assetName" TEXT NOT NULL,
    "panchayat" TEXT NOT NULL,
    "village" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "photoUrls" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "description" TEXT,
    "condition" "SurveyCondition" NOT NULL,
    "surveyDate" TIMESTAMP(3) NOT NULL,
    "surveyedById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Survey_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Survey_assetId_key" ON "Survey"("assetId");

-- CreateIndex
CREATE UNIQUE INDEX "User_staffId_key" ON "User"("staffId");

-- AddForeignKey
ALTER TABLE "Survey" ADD CONSTRAINT "Survey_surveyedById_fkey" FOREIGN KEY ("surveyedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
