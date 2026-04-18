#!/bin/bash
cp index.html index.html.bak

sed -i "s|__FIREBASE_API_KEY__|${FIREBASE_API_KEY}|g" index.html
sed -i "s|__FIREBASE_AUTH_DOMAIN__|${FIREBASE_AUTH_DOMAIN}|g" index.html
sed -i "s|__FIREBASE_PROJECT_ID__|${FIREBASE_PROJECT_ID}|g" index.html
sed -i "s|__FIREBASE_STORAGE_BUCKET__|${FIREBASE_STORAGE_BUCKET}|g" index.html
sed -i "s|__FIREBASE_MESSAGING_SENDER_ID__|${FIREBASE_MESSAGING_SENDER_ID}|g" index.html
sed -i "s|__FIREBASE_APP_ID__|${FIREBASE_APP_ID}|g" index.html
sed -i "s|__FIREBASE_MEASUREMENT_ID__|${FIREBASE_MEASUREMENT_ID}|g" index.html

echo "Firebase config injected successfully"
