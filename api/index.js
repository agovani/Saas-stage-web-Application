const express = require('express');
const basicAuth = require('express-basic-auth');


const app = express();
const port = process.env.PORT || 3000;


if (process.env.BASIC_AUTH_USER && process.env.BASIC_AUTH_PASS) {
app.use(basicAuth({
users: { [process.env.BASIC_AUTH_USER]: process.env.BASIC_AUTH_PASS },
challenge: true,
realm: 'Protected',
}));
}


app.get('/healthz', (req, res) => res.status(200).send('ok'));
app.get('/api/hello', (req, res) => res.json({ message: 'hello from api' }));


app.listen(port, () => console.log(`api listening on ${port}`));
