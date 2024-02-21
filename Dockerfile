# syntax = docker/dockerfile:1

FROM thatbballguy/materials:prod
EXPOSE 80
CMD ["foreman", "start", "--procfile=Procfile.prod"]
