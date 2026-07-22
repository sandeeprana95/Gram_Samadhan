import dotenv from "dotenv"
dotenv.config()

import path from "path"
import { fileURLToPath } from "url"
import express from "express"
import cors from "cors"
const app = express()

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const PORT = process.env.PORT || 8080

import authRoutes from "./routes/auth.routes.js"
import complaintRoutes from "./routes/complaint.routes.js"
import surveyRoutes from "./routes/survey.routes.js"
import notificationRoutes from "./routes/notification.routes.js"

app.use(cors())
app.use(express.json())
app.use(express.urlencoded({extended:true}))
app.use("/uploads", express.static(path.join(__dirname, "uploads")))

app.use("/api/auth",authRoutes)
app.use("/api/complaints",complaintRoutes)
app.use("/api/surveys",surveyRoutes)
app.use("/api/notifications",notificationRoutes)



app.get("/",(req,res)=>{
    res.status(200).json({
        success:true,
        message:"Gram Samadhan Backend running"
    })
})

app.listen(PORT,()=>{
    console.log(`server is running on port ${PORT}`)
})


