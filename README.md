# Tesi
Progettazione e implementazione di un meccanismo per associare OAuth access tokens al certificato X.509 di un client

## Development

### Run services
First, create or start the containers:
```bash
docker compose up -d
```

To run iam-dashboard:
```bash
docker exec -it iam-dev bash
cd workspace/iam-dashboard/
npm install
npm run dev
```

To run iam-login-service (with sql profile):
```bash
docker exec -it iam-dev bash
cd workspace/iam/
mvn clean install -DskipTests
mvn -pl iam-login-service -am spring-boot:run -Dspring.profiles.active=mysql-test,oidc,registration
```

### Create client
1. Access the old dashboard at http://iam.test.example:8080/
2. In the **Clients** page, create a new client and open its details
3. In the **Main** tab, add the redirect uri *http://iam.test.example:8080/ui/api/auth/callback/indigo-iam*
4. In the **Scopes** tab, add: *openid email profile scim:read scim:write iam:admin.read iam:admin.write*
5. In the **Crypto** tab, enable PKCE with SHA-256 algorithm
6. From **Main** and **Credentials** tabs, copy respectively *Client id* and *Client secret* to the `.env` file inside iam-dashboard
