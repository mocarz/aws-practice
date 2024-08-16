export const lambda_handler = async (event) => {
    console.log("event:", event)
    const weather_response = event.body
    return {
        temperature: weather_response.current.temp_c,
        city: weather_response.location.name,
        country: weather_response.location.country
    }
};