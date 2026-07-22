-- AlterTable
ALTER TABLE "Survey" ADD COLUMN "district" TEXT NOT NULL DEFAULT 'Unknown';
ALTER TABLE "Survey" ALTER COLUMN "district" DROP DEFAULT;
