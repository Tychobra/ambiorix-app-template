# Ambiorix Web App Template

A starter template for building web apps with an R Ambiorix backend and Solidjs frontend.

### Install JS Dependencies

```terminal
npm install
cd frontend_src && npm install
cd ..
```

### Run Locally for Development

```terminal
npm run dev
```

### Build for Production

```terminal
npm run prod
docker build -t ambiorix-plumber-web-app-template .

docker run -p 8080:8080 ambiorix-plumber-web-app-template
```
