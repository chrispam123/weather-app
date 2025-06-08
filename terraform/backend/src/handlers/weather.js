xports.handler = async (event) => {
    return {
        statusCode: 200,
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            message: 'Weather API is working!',
            city: event.pathParameters?.city || 'unknown',
            timestamp: new Date().toISOString(),
            status: 'success'
        })
    };
};