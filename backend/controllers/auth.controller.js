import prisma from "../config/prisma.js"

export const sendOtp = async(req,res)=>{
    try{
        const {mobile} = req.body;

        // Validate Mobile Number
        if(!mobile)
            return res.status(400).json({
               success:false,
               message:"Mobile Number is required"

            });

    if (!/^[6-9]\d(9)$/.test(mobile)){
        return res.status(400).json({
            success:false,
            message:"Invalid mobile Number"
        })
    }

    //Generate OTP
    const otp = Math.floor(100000 + Math.random()*900000).toString()

    //Expiry (5Minutes)
    const expiresAt = new Date(Date.now() + 5 * 60  * 1000 )

    // Remove old OTP for same mobile

    await prisma.otp.deleteMany({
        where:{
            mobile
        }
    })

    // Save OTP

    await prisma.otp.create({
        data:{
            mobile,
            opt,
            expiresAt
        }
    })

    console.log(`otp for ${mobile} : ${otp}`)

    return res.status(200).json({
        success:true,
        message:"OTP send successfully"
    })

}
catch(error){
    console.log(error)

    return res.status(500).json({
        success:false,
        message:"Internal server error",
        error:error.message

    })
}
    }
