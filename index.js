console.log("Hello from GitLab CI/CD!");
// Щоб контейнер не вимикався відразу, додамо нескінченний цикл або таймер
setInterval(() => {
  console.log("App is running...");
}, 10000);
