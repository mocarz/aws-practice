import * as http from 'http';

export const lambda_handler = async (event) => {
    console.log('my event:', event)
    const location = event.location

    const apiKey = process.env.weatherApiKey
    const url = `http://api.weatherapi.com/v1/current.json?key=${apiKey}&q=${location}&aqi=no`

    try {
        const getResponse = await httpGet(url)
        const temperature = JSON.parse(getResponse)
        return okResponse(temperature)
    } catch (error) {
        return badResponse(error)
    }
};

function okResponse(body) {
    return {
        statusCode: 200,
        body
    };
}

function badResponse(body) {
    return {
        statusCode: 200,
        body
    };
}

function httpGet(url) {
    return new Promise(function (resolve, reject) {
        http.get(url, (resp) => {
            let data = '';

            resp.on('data', (chunk) => {
                data += chunk;
            });

            resp.on('end', () => {
                resolve(data)
            });

        }).on("error", (err) => {
            reject(err.message)
        });
    });
}
