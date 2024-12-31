#!/bin/bash

# マイグレーションの実行
migrate -path migrations -database "$DATABASE_URL" "$@"