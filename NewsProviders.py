import socket
import numpy as np
from sklearn.linear_model import LinearRegression

class socketserver:
    def __init__(self, address='', port=9091):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.address = address
        self.port = port
        self.sock.bind((self.address, self.port))
        self.sock.listen(1)  # Mantener escuchando por conexiones
        print(f"Servidor escuchando en {self.address}:{self.port}")

    def recvmsg(self):
        self.sock.listen(1)
        self.conn, self.addr = self.sock.accept()
        print('connected to', self.addr)
        self.cummdata = ''

        while True:
            data = self.conn.recv(10000)
            print(data)
            self.cummdata+=data.decode("utf-8")
            if not data:
                break    
            self.conn.send(bytes(self.calcregr(self.cummdata), "utf-8"))
            return self.cummdata

    def calcregr(self, msg):
        try:
            chartdata = np.fromstring(msg, sep=' ')  # Convertir la cadena en un array de flotantes

            # Asegurarse de que chartdata tenga datos
            if chartdata.size == 0:
                raise ValueError("Los datos están vacíos o no son válidos.")

            Y = chartdata.reshape(-1, 1)
            X = np.arange(len(chartdata)).reshape(-1, 1)
            
            # Ajustar el modelo de regresión lineal
            lr = LinearRegression()
            lr.fit(X, Y)
            Y_pred = lr.predict(X)

            # Retornar los resultados
            return f"{Y_pred[-1][0]} {Y_pred[0][0]}"

        except Exception as e:
            print(f"Error en calcregr: {e}")
            return "Error en el cálculo"


    def __del__(self):
        self.sock.close()

host = "127.0.0.1"
port = 9091

try:
    server = socketserver(host, port)
    while True:
        server.recvmsg()  # Mantener el servidor recibiendo mensajes
except Exception as e:
    print(f"Error en el servidor: {e}")
