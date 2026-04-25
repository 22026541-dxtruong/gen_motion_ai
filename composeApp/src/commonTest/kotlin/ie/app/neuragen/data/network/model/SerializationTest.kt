package ie.app.neuragen.data.network.model

import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals

class SerializationTest {

    private val json = Json {
        ignoreUnknownKeys = true
    }

    @Test
    fun testAuthResponseSerialization() {
        val jsonString = """
            {
              "userId": "uuid",
              "username": "test",
              "email": "test@example.com",
              "accessToken": "jwt",
              "refreshToken": "jwt"
            }
        """.trimIndent()

        val response = json.decodeFromString<AuthResponse>(jsonString)
        assertEquals("uuid", response.userId)
        assertEquals("test", response.username)
        assertEquals("test@example.com", response.email)
    }

    @Test
    fun testUserMeDtoSerialization() {
        val jsonString = """
            {
              "id": "uuid",
              "email": "string",
              "username": "string",
              "avatarUrl": "string|null",
              "bio": "string|null",
              "role": "FREE",
              "proExpiresAt": null,
              "createdAt": "datetime",
              "credits": {
                "balance": 120,
                "updatedAt": "datetime"
              },
              "counts": {
                "followers": 0,
                "following": 0,
                "posts": 0,
                "jobs": 0
              },
              "jobs": {
                "data": [
                  {
                    "id": "uuid",
                    "type": "IMAGE_TO_VIDEO",
                    "status": "PENDING",
                    "progress": 0,
                    "prompt": "string",
                    "negativePrompt": "string|null",
                    "modelName": "string",
                    "turboEnabled": false,
                    "creditCost": 10,
                    "provider": "string|null",
                    "errorMessage": "string|null",
                    "createdAt": "datetime",
                    "updatedAt": "datetime",
                    "startedAt": "datetime|null",
                    "completedAt": "datetime|null",
                    "failedAt": "datetime|null"
                  }
                ],
                "nextCursor": null,
                "take": 20
              }
            }
        """.trimIndent()

        val response = json.decodeFromString<UserMeDto>(jsonString)
        assertEquals("uuid", response.id)
        assertEquals(120, response.credits.balance)
        assertEquals(1, response.jobs.data.size)
        assertEquals("IMAGE_TO_VIDEO", response.jobs.data[0].type)
    }
}
