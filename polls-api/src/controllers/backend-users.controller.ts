/*
 * Copyright 2022-2023 bitApp S.r.l.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Mimosa API
 *
 *
 * Contact: info@bitapp.it
 */

import { Request, Response } from "express";
import  jsonwebtoken  from "jsonwebtoken"
import { is_not_empty } from "../helpers/empty_functions.js";
import { create_user_backend, get_user_backend } from "../services/backend-users.service.js";
import { jwt_secret } from "../index.js";
import bcrypt from 'bcrypt'
export async function auth(req: Request, res: Response) {
    const { username, password } = req.body;
    
    const data = await get_user_backend(username);
    let token;
    
    if(is_not_empty(data.Item)){
        if(await bcrypt.compare(password, data.Item?.password)){
            try {
                //Creating jwt token
                token = jsonwebtoken.sign(
                    { user_name: username },
                    jwt_secret,
                    { expiresIn: '8h'}
                )
                res.status(200).send({token: token})
            } catch (error) {
                console.log(error)
                res.status(400);
            }
        }else {
            res.status(401).send({data: {"error": "Invalid credentials"}})
        }
    }else {
        res.status(401).send({data: {"error": "Invalid credentials"}})
    }
}

export async function register_user(req: Request, res: Response) {
    const { username, password } = req.body;
    const data  = await get_user_backend(username);
    
    if(is_not_empty(data.Item)){
        res.status(403).send({data: {"error": "User already exists"} });
    }else {
        try {
            let user = await create_user_backend(username, password)
            res.status(200).send({data : {username : user?.username, created_at : user?.info.created_at}})
        } catch (error) {
            console.log(error)
        }
        

    }
}
