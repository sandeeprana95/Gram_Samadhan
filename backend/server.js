import dotenv from "dotenv"
dotenv.config()

import express from "express"
import cors from "cors"
const app = express()

const PORT = process.env.PORT || 8080

app.use(cors())
app.use(express.json())
app.use(express.urlencoded({extended:true}))

app.get("/",(req,res)=>{
    res.status(200).json({
        success:true,
        message:"Gram Samadhan Backend running"
    })
})

app.listen(PORT,()=>{
    console.log(`server is running on port ${PORT}`)
})


