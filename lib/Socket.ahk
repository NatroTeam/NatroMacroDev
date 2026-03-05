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
        WSAData := Buffer(394 + A_PtrSize)
        if (err := DllCall("ws2_32\WSAStartup", "ushort", 0x0202, "ptr", WSAData.Ptr, "int")) > 0
            throw OSError(err)
        if NumGet(WSAData, 2, "ushort") != 0x0202
            throw Error("Winsock version 2.2 not available", -1)  
    }

    __New(Sock := -1) {
        if !(this is Socket.Server || this is Socket.Client)
            throw Error("This method can only be called from the Socket.Server or Socket.Client class.")
        this._sock := Sock
    }

    CreateSock() {
        static AF_INET := 2, SOCK_STREAM := 1, IPPROTO_TCP := 6
        if this._sock != -1 
            throw Error("Socket already exists", -1)
        if (this._sock := DllCall("ws2_32\socket", "int", AF_INET, "int", SOCK_STREAM, "int", IPPROTO_TCP)) = -1
            throw OSError(DllCall("ws2_32\WSAGetLastError"))
    }

    Createsockaddr(Host, Port) {
        if (h := DllCall("ws2_32\inet_addr", "astr", Host)) = -1
            throw Error("Invalid IP", -1)
        sockaddr := Buffer(16)
        NumPut("ushort", 2, sockaddr, 0)
        NumPut("ushort", DllCall("ws2_32\htons", "ushort", port), sockaddr, 2)
        NumPut("uint", h, sockaddr, 4)
        return sockaddr
    }

    AsyncSelect(Event, EventObject, WM := 0x5566) {
        if DllCall("ws2_32\WSAAsyncSelect", "ptr", this._sock, "ptr", A_ScriptHwnd, "uint", WM, "uint", Event, "int") = -1
            throw OSError(DllCall("ws2_32\WSAGetLastError"))
        OnMessage(WM, (wParam, lParam, msg, hWnd) => this.OnMessage(wParam, lParam, msg, hWnd, WM, EventObject))
    }

    OnMessage(wParam, lParam, msg, hWnd, WM, EventObject) {
        if msg != WM
            return
        if lParam & Socket.FD.ACCEPT && EventObject.HasMethod("Accept")
            (EventObject.Accept)(this)
        if lParam & Socket.FD.CLOSE && EventObject.HasMethod("Close")
            (EventObject.Close)(this)
        if lParam & Socket.FD.READ && EventObject.HasMethod("Receive")
            (EventObject.Receive)(this)
    }

    Close() {
        if this is Socket.Client
            if DllCall("ws2_32\shutdown", "ptr", this._sock, "int", 2) != 0
                throw OSError(DllCall("ws2_32\WSAGetLastError"))
        if DllCall("ws2_32\closesocket", "ptr", this._sock) = -1
            throw OSError(DllCall("ws2_32\WSAGetLastError"))
    }

    Cleanup() {
        if DllCall("ws2_32\WSACleanup", "int") != 0
            throw OSError(DllCall("ws2_32\WSAGetLastError"))
    }

    class Server extends Socket {
        static __New() => 0

        Bind(Host, Port, sockaddr?) {
            if this._sock = -1
                this.CreateSock()
            if !IsSet(sockaddr)
                sockaddr := this.Createsockaddr(Host, Port)
            if DllCall("ws2_32\bind", "ptr", this._sock, "ptr", sockaddr.Ptr, "int", sockaddr.Size) = -1
                throw OSError(DllCall("ws2_32\WSAGetLastError"))
        }

        Listen(Backlog := 10) {
            if DllCall("ws2_32\listen", "ptr", this._sock, "int", Backlog) = -1
                throw OSError(DllCall("ws2_32\WSAGetLastError"))
        }

        Accept() {
            if (sock := DllCall("ws2_32\accept", "ptr", this._sock, "ptr", 0, "ptr", 0)) = -1
                if (err := DllCall("ws2_32\WSAGetLastError"))
                    throw OSError(err)
            return sock
        }
    }
    class Client extends Socket {
        static __New() => 0

        Connect(Host, Port, sockaddr?) {
            if this._sock = -1
                this.CreateSock()
            if !IsSet(sockaddr)
                sockaddr := this.Createsockaddr(Host, Port)
            if DllCall("ws2_32\connect", "ptr", this._sock, "ptr", sockaddr.Ptr, "int", sockaddr.Size) = -1
                throw OSError(DllCall("ws2_32\WSAGetLastError"))
        }

        ReceiveRaw(MessageBuffer) {
            size := DllCall("ws2_32\recv", "ptr", this._sock, "ptr", MessageBuffer.Ptr, "int", MessageBuffer.Size, "int", 0, "int")
            if size = -1
                if (err := DllCall("ws2_32\WSAGetLastError"))
                    throw OSError(err)
            return size
        }

        ReceiveText(BufferSize := 256, Encoding := "UTF-8") {
            buf := Buffer(BufferSize)
            length := this.ReceiveRaw(buf)
            return StrGet(buf, length, Encoding)
        }

        SendRaw(MessageBuffer) {
            if DllCall("ws2_32\send", "ptr", this._sock, "ptr", MessageBuffer.Ptr, "int", MessageBuffer.Size, "int", 0, "int") = -1
                if (err := DllCall("ws2_32\WSAGetLastError"))
                    throw OSError(err)
        }

        SendText(Message, Encoding := "UTF-8") {
            buf := Buffer(StrPut(Message, "UTF-8"))
            StrPut(Message, buf, "UTF-8")
            this.SendRaw(buf)
        }
    }
}
