# Redovisning – Fullständig deployment av CRUD-applikation (Alternativ B)

## 1. Syfte och kravuppfyllelse

Målet med projektet var att genomföra en komplett deployment av en CRUD-applikation med följande krav:

- **Frontend** byggs och levereras via **AWS Amplify** (automatisk deploy vid git push).
- **Backend** körs containeriserat i **AWS ECS Fargate**.
- **Databas** ligger i **Amazon RDS**, i privat nät (private IP), skyddad med **Security Groups**.
- **Backend ↔ Databas** sker endast via säkerhetsgrupper (inga publika portar till databasen).
- **CI/CD** för backend:
  - **AWS CodeBuild** bygger backend och pushar image till **ECR**
  - **AWS CodeDeploy** rullar ut ny version till **ECS**

All infrastruktur och konfiguration är skapad med **Terraform** och lösningen är fullt deployad och verifierad som fungerande.

---

## 2. Översikt av arkitektur

### 2.1 Komponenter

- **Amplify**: bygger och hostar frontend (CI/CD kopplat till git).
- **ALB (Application Load Balancer)**: publik entrypoint för backend-API.
- **ECS Fargate**: kör backend som container-tasks.
- **ECR**: container registry för backend-image.
- **RDS**: relationsdatabas i privata subnät, ej publik.
- **CodeBuild**: bygger/pushar backend-image.
- **CodeDeploy**: deployar backend till ECS (rolling/blue-green beroende på konfiguration).
- **VPC + Subnets + SG**: nätsegmentering och åtkomstkontroll.

### 2.2 Trafikflöde (hög nivå)

1. Användare öppnar **frontend (Amplify)**.
2. Frontend anropar backend via **ALB** (HTTP).
4. CloudFont används mellan ALB och frontend för att kunna omdiregera till ALB på grund av HTTPS - HTTP policy (mixed content errors)
3. ALB vidarebefordrar trafik till **ECS service** (Fargate tasks).
4. Backend ansluter till **RDS** via privat nät och **SG-regler**.

---

## 3. Infrastruktur (Terraform)

### 3.1 Nätverk

- VPC med separata **public** och **private subnets**.
- **ALB** ligger i public subnets (publik åtkomst).
- **ECS tasks** ligger i private subnets (ej direktpublika).
- **RDS** ligger i private subnets och saknar publik endpoint.

### 3.2 Security Groups (princip)

- **ALB-SG**
  - Inbound: 443 (ev. 80→443 redirect) från internet
  - Outbound: till ECS-SG på app-port
- **ECS-SG**
  - Inbound: endast från ALB-SG på app-port
  - Outbound: till DB-SG på DB-port (t.ex. 5432/3306)
- **RDS-SG**
  - Inbound: endast från ECS-SG på DB-port
  - Public access: avstängt (ingen publik ingress)

---

## 4. CI/CD – deploymentskedja

### 4.1 Frontend – Amplify

- Amplify är kopplat till git-repo.
- Vid push till vald branch triggas:
  1) build  
  2) deploy  
- Resultat: ny frontend-version blir live automatiskt.

### 4.2 Backend – CodeBuild → ECR → CodeDeploy → ECS

- **CodeBuild**:
  - Kör build (t.ex. docker build)
  - Taggar image (t.ex. commit hash / latest)
  - Pushar image till **ECR**
- **CodeDeploy**:
  - Hämtar ny image-referens
  - Rullar ut ny task definition i ECS
  - Uppdaterar service (rolling/blue-green beroende på setup)
- **ECS**:
  - Nya tasks startas
  - Hälsokontroller passerar via ALB target group
  - Gamla tasks dräneras/stängs

---

## 5. Test och verifiering

### 5.1 Funktionellt test (CRUD)

Följande verifierades mot backend via **ALB DNS**.

Exempel med `curl`:

```bash
# CREATE
curl -X 'POST' \
  'http://demo-demo-alb-419669768.eu-north-1.elb.amazonaws.com/api/pokemon/add/lugia' \
  -H 'accept: */*' \
  -d ''

# READ (list)
curl "http://demo-demo-alb-419669768.eu-north-1.elb.amazonaws.com/api/pokemons"

# DELETE
curl -X DELETE "http://demo-demo-alb-419669768.eu-north-1.elb.amazonaws.com/api/pokemons/api/pokemon/<id>" for example if added squirtle, then you would have to add squirtles ID to delete it which would be 7.
```

### 5.2 Verifiering av databas-åtkomst

- Backend kan läsa/skriva till databasen.
- Databasen är inte nåbar publikt.
- Endast ECS-SG har tillåtelse till DB-port (via SG-referens).

## 6. Säkerhetsmodell (kort)

### 6.1 Nätverkssegmentering

- Publik yta: endast **ALB** (och frontend via Amplify).
- Privat yta: **ECS tasks** och **RDS**.
- Databasen saknar publik exponering.

### 6.2 Minsta privilegium (IAM)

- CodeBuild har endast rättigheter för build + push till ECR (och nödvändiga loggar).
- CodeDeploy har rättigheter för ECS deploy.
- ECS task role har endast rättigheter som backend behöver (t.ex. läsa secrets).

### 6.3 Observability

- Loggar i **CloudWatch** för felsökning och spårbarhet.
- Hälsokontroller via ALB target group.

---

## 7. Hur AI användes

AI användes som stöd i arbetet för:

- Arkitekturplanering (val av AWS-tjänster där budget ska vara optimerad och passad för 100$ free credits och trafikflöde).
- Felsökning (tolkning av felmeddelanden från Terraform/AWS, exempelvis SG-regler och IAM-policyer).

---

## 8. Bilaga – Skärmbilder (15–25 st) med kort beskrivning

1. **Skärmbild 1 – Amplify: App overview**  
   [amplify](https://gyazo.com/f3f480f7e323042970015d8b7666d004)  
   _Visar Amplify-applikationen och att frontend är deployad samt vilken branch som används._

2. **Skärmbild 2 – Amplify: Senaste build/deploy**  
   [amplify](https://gyazo.com/a38b4049ebabffda2727b4745b2cf1e2)
   _Visar senaste build-logg och status “Succeeded” efter git push._

3. **Skärmbild 3 – Frontend: Startvy**  
   [amplify](https://gyazo.com/80fa2264e032fc1fe5b8b91c2dd37d7c)  
   _Visar att frontend laddar korrekt från Amplify-hosting._

4. **Skärmbild 4 – ALB: Listener + rules**  
   [ALB listeners & rules](https://gyazo.com/142a049b0b624c99e2e77638039664cc)  
   _Visar att ALB tar emot trafik (t.ex. 80) och routar till rätt target group._

6. **Skärmbild 6 – ALB: Target group health**  
   [TG-BLUE](https://gyazo.com/e8fae717c5f54e21346ddf129894255d)  
   _Visar att ECS tasks är “healthy” i target group._

7. **Skärmbild 7 – ECS Cluster**  
   [ECS](https://gyazo.com/e1cff9e6c0207fd2ebdcf5911b53a380)  
   _Visar ECS-clustret där backend körs._

8. **Skärmbild 8 – ECS Service**  
   [SVC](https://gyazo.com/ab0af0b6b932c01ab4ac3cf5a80675b0)  
   _Visar service-konfiguration och desired/running tasks._

9. **Skärmbild 9 – ECS Task definition (image + env/secrets)**  
   [ECS-TASK](https://gyazo.com/17f283aaeec85735792ddfb918e510da)  
   _Visar container image från ECR och hur konfiguration/secrets matas in._

10. **Skärmbild 10 – ECR Repository**  
    [ECR](https://gyazo.com/3acfa9e1e18c18b104a5fd009ce852dd)  
    _Visar backend-images och tags/digests efter CodeBuild push._

11. **Skärmbild 11 – CodeBuild Project**  
    [CodeBuild](https://gyazo.com/ddb42e985f4c8a94bed1e0982f441142)  
    _Visar CodeBuild-projektet som bygger backend._

12. **Skärmbild 12 – CodeBuild: Build history / log**  
    [BuildHistory](https://gyazo.com/c9c9498a14b9debb14204a3e3dcd7033)  
    _Visar en lyckad build och relevanta buildsteg (build, tag, push)._

13. **Skärmbild 13 – CodeDeploy Application**  
    [CodeDeploy](https://gyazo.com/b0a8a19e51c6f9d8097ed5f5182db043)  
    _Visar CodeDeploy-applikation kopplad till ECS._

14. **Skärmbild 14 – CodeDeploy Deployment (senaste)**  
    [codeDeploy](https://gyazo.com/6b557c03590f34a135ea5b8e11eb6b7d)  
    _Visar senaste deployment-status och att rollout lyckades._

15. **Skärmbild 15 – RDS: Databasinstans (Connectivity/Security)**  
    [RDS/postgres](https://gyazo.com/99dc02d9b01adf5efa497b25b758555b)  
    _Visar att databasen inte är publik och ligger i privata subnät (private IP / Public access: No)._

16. **Skärmbild 16 – VPC/Subnets (public/private)**  
    [VPC](https://gyazo.com/bd57bb7070764bfbea2f66434e3b420e)  
    _Visar nätindelningen och var ALB/ECS/RDS är placerade._

17. **Skärmbild 17 – Security Groups:**  
    [Security-Group](https://gyazo.com/5cce8c41ceac67df6c45bd5fc053438a)  
   
18. **Skärmbild 18 – API-test (Postman/curl resultat)**  
    [Postman](https://gyazo.com/a48229be165e3e674cb0a0d7a87bc43c)  
    _Visar exempel på lyckade CRUD-anrop mot ALB-DNS samt svarskoder och responsbody._

19. **Skärmbild 19 – CloudWatch Logs (backend)**  
    [Cloudwatch-ECS](https://gyazo.com/5b730210f3858cbd4d81bf1d0b0736c4)  
    _Visar loggar som bekräftar API-anrop och eventuella DB-queries._


## 9. Slutsats

Projektet levererar en komplett CRUD-applikation enligt kraven: frontend via Amplify, backend i ECS Fargate, RDS privat och skyddad, samt CI/CD där frontend deployas via git push och backend byggs (CodeBuild) och deployas (CodeDeploy) till ECS. Säkerhetsmodellen bygger på privata subnät och security group-referenser, där endast ALB och Amplify är publikt exponerad.
