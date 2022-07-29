B1: Cài yarn -> Bật terminal, chạy command: yarn

B2: Tạo file .env (copy từ .example.env, thêm private key vao, sửa contract, contract name tương ứng)

B3: Chạy testnet: -> yarn run mint-testnet 

B4: Chạy mainnet: -> yarn run mint-testnet 

Nếu muốn config gas cao lên thì vào hardhat.config.ts
Tìm networks->mainnet->gasPrice, networks->testnet->gasPrice, tăng giá trị đó lên
