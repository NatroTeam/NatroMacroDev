/********************************************
* @Author Myurius
* @Description Class for socket communication
********************************************
*/

#DllLoad "ws2_32.dll"
class Socket {
    static FD => {
        READ: 0x01,
        ACCEPT: 0x08,
        CLOSE: 0x20
    }

    static __New() {
        WSADATA := Buffer(396 + A_PtrSize)
        if (err := DllCall("ws2_32\WSAStartup", "ushort", 0x0202, "ptr", WSADATA.Ptr, "int")) != 0
            throw OSError(err)
        if NumGet(WSADATA, 2, "ushort") != 0x0202
            throw Error("Winsock version 2.2 not available", -1)  
    }

    __New(sock := -1) {
        if !(this is Socket.Server || this is Socket.Client)
            throw Error("This method can only be called from the Socket.Server or Socket.Client class.")
        this._sock := sock
    }

    CreateSock() {
        static AF_INET := 2, SOCK_STREAM := 1, IPPROTO_TCP := 6
        if this._sock != -1 
            throw Error("Socket already exists", -1)
        if (this._sock := DllCall("ws2_32\socket", "int", AF_INET, "int", SOCK_STREAM, "int", IPPROTO_TCP)) = -1
            throw OSError(this.GetLastError())
    }

    Createsockaddr(host, port) {
        static AF_INET := 2
        if (h := DllCall("ws2_32\inet_addr", "astr", host)) = -1
            throw Error("Invalid IP", -1)
        sockaddr := Buffer(16)
        NumPut("ushort", AF_INET, sockaddr)
        NumPut("ushort", DllCall("ws2_32\htons", "ushort", port), sockaddr, 2)
        NumPut("uint", h, sockaddr, 4)
        return sockaddr
    }

    AsyncSelect(Event, event_object, WM := 0x5566) {
        result :=  DllCall("ws2_32\WSAAsyncSelect",
            "ptr", this._sock,
            "ptr", A_ScriptHwnd,
            "uint", WM,
            "uint", Event,
            "int")
        if result = -1
            throw OSError(this.GetLastError())
        OnMessage(WM, (wParam, lParam, msg, hWnd) => this.OnMessage(wParam, lParam, msg, hWnd, WM, event_object))
    }

    OnMessage(wParam, lParam, msg, hWnd, WM, event_object) {
        if msg != WM
            return
        if lParam & Socket.FD.ACCEPT && event_object.HasMethod("Accept")
            (event_object.Accept)(this)
        if lParam & Socket.FD.CLOSE && event_object.HasMethod("Close")
            (event_object.Close)(this)
        if lParam & Socket.FD.READ && event_object.HasMethod("Receive")
            (event_object.Receive)(this)
    }

    Close() {
        static SD_BOTH := 2
        if this is Socket.Client
            if DllCall("ws2_32\shutdown", "ptr", this._sock, "int", SD_BOTH) != 0
                throw OSError(this.GetLastError())
        if DllCall("ws2_32\closesocket", "ptr", this._sock) = -1
            throw OSError(this.GetLastError())
    }

    Cleanup() {
        if DllCall("ws2_32\WSACleanup", "int") != 0
            throw OSError(this.GetLastError())
    }

    GetLastError() => DllCall("ws2_32\WSAGetLastError", "int")

    class Server extends Socket {
        static __New() => 0

        Bind(host, port, sockaddr?) {
            if this._sock = -1
                this.CreateSock()
            if !IsSet(sockaddr)
                sockaddr := this.Createsockaddr(host, port)
            if DllCall("ws2_32\bind", "ptr", this._sock, "ptr", sockaddr.Ptr, "int", sockaddr.Size) = -1
                throw OSError(this.GetLastError())
        }

        Listen(backlog := 10) {
            if DllCall("ws2_32\listen", "ptr", this._sock, "int", backlog) = -1
                throw OSError(this.GetLastError())
        }

        Accept() {
            if (sock := DllCall("ws2_32\accept", "ptr", this._sock, "ptr", 0, "ptr", 0)) = -1
                if (err := this.GetLastError())
                    throw OSError(err)
            return sock
        }
    }
    class Client extends Socket {
        static __New() => 0

        Connect(host, port, sockaddr?) {
            if this._sock = -1
                this.CreateSock()
            if !IsSet(sockaddr)
                sockaddr := this.Createsockaddr(host, port)
            if DllCall("ws2_32\connect", "ptr", this._sock, "ptr", sockaddr.Ptr, "int", sockaddr.Size) = -1
                throw OSError(this.GetLastError())
        }

        ReceiveRaw(message_buffer) {
            static flags := 0
            size := DllCall("ws2_32\recv",
                "ptr", this._sock,
                "ptr", message_buffer.Ptr,
                "int", message_buffer.Size,
                "int", flags,
                "int")
            if size = -1
                throw OSError(this.GetLastError())
            return size
        }

        ReceiveText(buffer_size := 256, encoding := "UTF-8") {
            buf := Buffer(buffer_size)
            length := this.ReceiveRaw(buf)
            return StrGet(buf, length, encoding)
        }

        SendRaw(message_buffer) {
            static flags := 0
            result := DllCall("ws2_32\send",
                "ptr", this._sock,
                "ptr", message_buffer.Ptr,
                "int", message_buffer.Size,
                "int", flags,
                "int")
            if result = -1
                throw OSError(this.GetLastError())
        }

        SendText(message, encoding := "UTF-8") {
            buf := Buffer(StrPut(message, encoding))
            StrPut(message, buf, encoding)
            this.SendRaw(buf)
        }
    }
}
