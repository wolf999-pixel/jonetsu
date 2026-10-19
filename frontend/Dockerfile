FROM cirrusci/flutter:stable
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get
COPY . .
