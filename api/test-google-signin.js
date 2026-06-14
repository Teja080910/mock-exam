const axios = require('axios');

const token = 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImE0YTEwZGVjZTk4MzY2ZDZmNjNlMTY3Mjg2YWU5YjYxMWQyYmFhMjciLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiRGVsdG9zcGFyayIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BQ2c4b2NLYXQtNDRVZlM2NElpUkJMSUZ1OEc0eVNoLVFZX0RRaEtaaW1fZnJHTDE2eEZtOV80PXM5Ni1jIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL21vY2stdGVzdC1mNzRlNyIsImF1ZCI6Im1vY2stdGVzdC1mNzRlNyIsImF1dGhfdGltZSI6MTc1MDE1OTExOSwidXNlcl9pZCI6IkVJYU5RcDNaZWpXOTBOMmhLR1pZeG9MMjJEMzIiLCJzdWIiOiJFSWFOUXAzWmVqVzkwTjJoS0daWXhvTDIyRDMyIiwiaWF0IjoxNzUwMTY2MTk1LCJleHAiOjE3NTAxNjk3OTUsImVtYWlsIjoiZGVsdG9zcGFya3NAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDMzOTEzNDc0NTUxNzUxNDM1MDMiXSwiZW1haWwiOlsiZGVsdG9zcGFya3NAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.bJBu0l-5H2htJnBxGX1_c21Ezn1iTdzHh9_foqTibJv9nGOED8Wrh9vqwFjaLDkHDmMz2EpJZJBsjlLnoR-b1xAK8Bp0PPBmgomH892japQKbNXGPOp1bmPCKmgpCF2nok09u2J8uQYRqM8VWwZycMDjnxWgGoBs7sC7yQv1rk2w9bMK7nZjEQEqT';

async function testGoogleSignIn() {
    try {
        console.log('Sending request to Google Sign-In endpoint...');
        const response = await axios.post('https://quiz.deltospark.com/api/google-signin', {
            token,
            deviceId: 'AP3A.240905.015.A2'
        }, {
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        console.log('Response:', response.data);
    } catch (error) {
        console.error('Error:', error.response ? error.response.data : error.message);
    }
}

testGoogleSignIn(); 