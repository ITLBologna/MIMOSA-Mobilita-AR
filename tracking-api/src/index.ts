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

import express, { Application, Express, Request, Response } from "express";
import jsonwebtoken from "jsonwebtoken";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import cors from "cors";
import dotenv from "dotenv";
dotenv.config();
import jsonschema from "jsonschema";
import {
  GetCommand,
  PutCommand,
  ScanCommand,
  QueryCommand,
  UpdateCommand,
} from "@aws-sdk/lib-dynamodb";

const PORT = process.env.PORT;
const access_key: any = process.env.ACCESS_KEY_ID;
const secret_key: any = process.env.SECRET_ACCESS_KEY;
const region: any = process.env.REGION;
const tracking_data: any = process.env.TABLE_NAME_TRACKING_DATA;
const users: any = process.env.TABLE_NAME_USERS;
const app: Application = express();
const jwt_secret: any = process.env.JWT_SECRET;

const allowCrossDomain = (req: Request, res: Response, next: any) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Methods",
    "GET,POST,PUT,DELETE,PATCH,OPTIONS"
  );
  res.header("Access-Control-Allow-Headers", "Content-Type");
  next();
};

app.use(express.json({ limit: "10mb" }));
app.use(cors());
app.options("*", cors());
app.use(allowCrossDomain);

const client = new DynamoDBClient({
  region: region,
  credentials: {
    accessKeyId: access_key,
    secretAccessKey: secret_key,
  },
});

//post in trackingdata
app.post("/data", (req, res) => {
  let json_data = req.body;

  let schema = {
    type: "object",
    properties: {
      user_id: { type: "string" },
      tracking_posixtime: { type: "number" },
      tracking_data: {
        type: "array",
        items: {
          properties: {
            posix_time: { type: "number" },
            lat: { type: "number" },
            lon: { type: "number" },
            speed: { type: "number" },
            heading: { type: "number" },
            activity: {
              type: "string",
              enum: [
                "IN_VEHICLE",
                "ON_BICYCLE",
                "RUNNING",
                "STILL",
                "WALKING",
                "UNKNOWN",
              ],
            },
          },
          additionalProperties: false,
          required: [
            "posix_time",
            "lat",
            "lon",
            "speed",
            "heading",
            "activity",
          ],
        },
      },
    },
    additionalProperties: false,
    required: ["user_id", "tracking_data"],
  };

  let Validator = jsonschema.Validator;
  let v = new Validator();
  const valid = v.validate(json_data, schema);

  const putItem = async () => {
    const params = {
      TableName: tracking_data,
      Item: {
        user_id: valid.instance.user_id,
        tracking_posixtime: Date.now(),
        tracking_data: valid.instance.tracking_data,
      },
      ReturnValues: "ALL_OLD",
    };

    let params2 = {
      TableName: users,
      Key: {
        user_id: valid.instance.user_id,
      },
      ConditionExpression: "attribute_exists(user_id) ",
      UpdateExpression: "set updated_at = :r",
      ExpressionAttributeValues: {
        ":r": Date.now(),
      },
      ReturnValues: "ALL_NEW",
    };

    if (valid.errors.length != 0) {
      res.status(400).send({ data: valid.errors });
    } else {
      try {
        const data = await client.send(new PutCommand(params));
        const data2 = await client.send(new UpdateCommand(params2));
        res.send({ data: [params.Item] });
        //console.log("Successo");
      } catch (err) {
        console.log("Error", err);
        res.sendStatus(400);
      }
    }
  };
  putItem();
});

//get  by user_id
app.get("/data/:user_id", (req, res) => {
  const bearer: any = req.headers.bearer;
  const scanTable = async () => {
    const user_id = req.params.user_id;

    const params = {
      KeyConditionExpression: "user_id = :user_id and tracking_posixtime > :e",
      ExpressionAttributeValues: {
        ":user_id": user_id,
        ":e": 0,
      },
      TableName: tracking_data,
    };

    try {
      const data: any = await client.send(new QueryCommand(params));

      let items_length: any = data.Items?.length;
      let coordinates: any = [];

      let users = data.Items?.sort(function (a: any, b: any) {
        return b.tracking_posixtime - a.tracking_posixtime;
      });

      for (let i = 0; i < items_length; i++) {
        let tracking_data_length = users.at(i)?.tracking_data.length;
        for (let y = 0; y < tracking_data_length; y++) {
          coordinates.push([
            users.at(i)?.tracking_data[y].lon,
            users.at(i)?.tracking_data[y].lat,
          ]);
        }
      }

      let response = {
        type: "Feature",
        properties: {
          user_id: users.at(0)?.user_id,
        },
        geometry: {
          type: "MultiPoint",
          coordinates: coordinates,
        },
      };

      res.send({ data: response });
    } catch (err) {
      console.log("Error", err);
    }
  };

  if (!validate_token(bearer)) {
    res.sendStatus(401);
  } else {
    scanTable();
  }
});

//get  by user_id
app.get("/data/:user_id/:tracking_posixtime", (req, res) => {
  const getItems = async () => {
    const user_id = req.params.user_id;
    const tracking_posixtime = req.params.tracking_posixtime;

    let params = {
      TableName: tracking_data,
      Key: {
        user_id: user_id,
        tracking_posixtime: parseInt(tracking_posixtime),
      },
    };
    try {
      const data = await client.send(new GetCommand(params));
      +res.send({ data: data.Item });
    } catch (err) {
      console.log("Error", err);
      res.sendStatus(400);
    }
  };
  getItems();
});

app.get("/users", (req, res) => {
  const bearer: any = req.headers.bearer;
  const scanTable = async () => {
    let params = {
      TableName: users,
    };

    try {
      const data = await client.send(new ScanCommand(params));
      //console.log(data);

      let users: any = data.Items;

      let response = users
        .map(function (user: any) {
          return {
            user_id: user.user_id,
            last_posixtime: user.updated_at,
          };
        })
        .sort(function (a: any, b: any) {
          return b.last_posixtime - a.last_posixtime;
        });

      res.status(200).send({ data: response });
    } catch (err) {
      console.log("Error", err);
      res.sendStatus(400);
    }
  };
  if (!validate_token(bearer)) {
    res.sendStatus(401);
  } else {
    scanTable();
  }
});

function validate_token(bearer: string) {
  try {
    const decode_token = jsonwebtoken.verify(bearer, jwt_secret);
    return true;
  } catch (error) {
    console.log(error);
    return false;
  }
}

app.listen(PORT, () => {
  console.log("Server is running on port", PORT);
});
