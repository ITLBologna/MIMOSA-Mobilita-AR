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


import express, { Application, Request, Response } from 'express';
import OpenApiValidator from "express-openapi-validator";
import dotenv from 'dotenv'
import cors from 'cors'
import api from './routes.js';
dotenv.config();

const PORT = process.env.PORT;

export const polls: any = process.env.TABLE_NAME_POLLS
export const pollsAnswers: any = process.env.TABLE_NAME_POLLS_ANSWERS
export const users: any = process.env.TABLE_NAME_USERS
export const games: any = process.env.TABLE_NAME_GAMES
export const users_backend: any = process.env.TABLE_NAME_USERS_BACKEND
export const jwt_secret: any = process.env.SECRET_JWT_KEY
export const gamificationEnabled: boolean = process.env.GAMIFICATION_ENABLED === 'true'
export const leaderboardEnabled: boolean = process.env.LEADERBOARD_ENABLED === 'true'

const allowCrossDomain = (req: Request, res: Response, next: any) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,PATCH,OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next();
}

const app: Application = express();
app.use(express.json());

app.use(cors())
app.options('*', cors())
app.use(
    allowCrossDomain
);

if (process.env.NODE_ENV === 'development') {
    app.use(
        OpenApiValidator.middleware({
            apiSpec: 'openapi.yaml',
            validateResponses: false,
            validateRequests: {
                removeAdditional: "all",
            },
        }),
    );
}



app.use(api);

app.listen(PORT, () => {
    console.log("Server is running on port", PORT);
});


