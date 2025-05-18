###############################################################################
# ── Etapa 1: BUILD ──                                                        #
###############################################################################
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

# -------------- BUILD-ARGS --------------
ARG ANDROID_CLIENT_ID
ARG API_HOST
ARG BASE_GOOGLE_PLACES_URL
ARG IOS_CLIENT_ID
ARG MAPS_API_KEY
ARG STRIPE_PAYMENT_API_URL
ARG STRIPE_PUBLIC_KEY
ARG STRIPE_SECRET_KEY
ARG SUPABASE_ANON_KEY
ARG SUPABASE_SERVICE_ROLE_KEY
ARG SUPABASE_URL
ARG WEB_CLIENT_ID
ARG RATINGS_ENABLED
ARG CHAT_ENABLED
ARG THIRD_AUTH_ENABLED
ARG REALTIME_TRACKING_ENABLED
ARG CASH_ENABLED
ARG CREDIT_CARD_ENABLED

# ----- genera assets/.env para flutter_dotenv -----
RUN printf '%s\n' \
  "ANDROID_CLIENT_ID=$ANDROID_CLIENT_ID" \
  "API_HOST=$API_HOST" \
  "BASE_GOOGLE_PLACES_URL=$BASE_GOOGLE_PLACES_URL" \
  "IOS_CLIENT_ID=$IOS_CLIENT_ID" \
  "MAPS_API_KEY=$MAPS_API_KEY" \
  "STRIPE_PAYMENT_API_URL=$STRIPE_PAYMENT_API_URL" \
  "STRIPE_PUBLIC_KEY=$STRIPE_PUBLIC_KEY" \
  "STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY" \
  "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" \
  "SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY" \
  "SUPABASE_URL=$SUPABASE_URL" \
  "WEB_CLIENT_ID=$WEB_CLIENT_ID" \
  "RATINGS_ENABLED=$RATINGS_ENABLED" \
  "CHAT_ENABLED=$CHAT_ENABLED" \
  "THIRD_AUTH_ENABLED=$THIRD_AUTH_ENABLED" \
  "REALTIME_TRACKING_ENABLED=$REALTIME_TRACKING_ENABLED" \
  "CASH_ENABLED=$CASH_ENABLED" \
  "CREDIT_CARD_ENABLED=$CREDIT_CARD_ENABLED" \
> .env

RUN flutter pub get
RUN flutter build web

###############################################################################
# ── Etapa 2: RUNTIME ──                                                     #
###############################################################################
FROM python:3.12-slim

WORKDIR /srv
COPY --from=build /app/build/web ./

# ---------- script de arranque condicional ----------
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8001
ENTRYPOINT ["/entrypoint.sh"]
