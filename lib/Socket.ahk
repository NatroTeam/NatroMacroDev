/********************************************
* @Author Myurius
* @Description Class for socket communication
********************************************
*/

#DllLoad "ws2_32.dll"
class Socket {
    static FD => {
        READ: 0x1,
        ACCEPT: 0x8,
        CLOSE: 0x20
    }

    static __New() {
        WSADATA := Buffer(396 + A_PtrSize)
        err := DllCall("ws2_32\WSAStartup",
            "ushort", 0x0202,   ; [in] WORD wVersionRequired
            "ptr", WSADATA.Ptr, ; [out] LPWSADATA lpWSAData
            "int")              ; int
        if err != 0
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
        static AF_INET := 2, SOCK_STREAM := 1, IPPROTO_TCP := 6, SOCKET_ERROR := -1
        if this._sock != -1 
            throw Error("Socket already exists", -1)
        
        this._sock := DllCall("ws2_32\socket",
            "int", AF_INET,     ; [in] int af
            "int", SOCK_STREAM, ; [in] int type
            "int", IPPROTO_TCP, ; [in] int protocol
            "ptr")              ; SOCKET WSAAPI
        if this._sock = SOCKET_ERROR
            throw this.WSAError()
    }

    Createsockaddr(host, port) {
        static AF_INET := 2, INADDR_NONE := 0xffffffff
        h := DllCall("ws2_32\inet_addr",
            "astr", host ; const char *cp
            "uint")      ; unsigned long
        if h = INADDR_NONE
            throw Error("Invalid IP", -1)
        p := DllCall("ws2_32\htons",
            "ushort", port ; [in] u_short hostshort
            "ushort")      ; u_short

        sockaddr := Buffer(16)
        NumPut("ushort", AF_INET, sockaddr)
        NumPut("ushort", p, sockaddr, 2)
        NumPut("uint", h, sockaddr, 4)
        return sockaddr
    }

    AsyncSelect(event, eventObject, WM := 0x5566) {
        static SOCKET_ERROR := -1
        result := DllCall("ws2_32\WSAAsyncSelect",
            "ptr", this._sock,   ; [in] SOCKET s
            "ptr", A_ScriptHwnd, ; [in] HWND   hWnd
            "uint", WM,          ; [in] u_int  wMsg
            "uint", event,       ; [in] long   lEvent
            "int")               ; int
        if result = SOCKET_ERROR
            throw this.WSAError()
        OnMessage(WM, (wParam, lParam, msg, hWnd) => this.OnMessage(wParam, lParam, msg, hWnd, WM, eventObject))
    }

    OnMessage(wParam, lParam, msg, hWnd, WM, eventObject) {
        if msg != WM
            return
        if lParam & Socket.FD.ACCEPT && eventObject.HasMethod("Accept")
            (eventObject.Accept)(this)
        if lParam & Socket.FD.CLOSE && eventObject.HasMethod("Close")
            (eventObject.Close)(this)
        if lParam & Socket.FD.READ && eventObject.HasMethod("Receive")
            (eventObject.Receive)(this)
    }

    Close() {
        static SD_BOTH := 2, SOCKET_ERROR := -1
        if this is Socket.Client {
            result := DllCall("ws2_32\shutdown",
                "ptr", this._sock, ; [in] SOCKET s
                "int", SD_BOTH,    ; [in] int how
                "int")             ; int
            if result = SOCKET_ERROR
                throw this.WSAError()
        }
        result := DllCall("ws2_32\closesocket",
            "ptr", this._sock, ; [in] SOCKET s
            "int")             ; int
        if result = SOCKET_ERROR
            throw this.WSAError()
    }

    Cleanup() {
        static SOCKET_ERROR := -1
        if DllCall("ws2_32\WSACleanup", "int") = SOCKET_ERROR
            throw this.WSAError()
    }

    WSAError() => OSError(DllCall("ws2_32\WSAGetLastError", "int"))

    class Server extends Socket {
        static __New() => 0

        Bind(host, port, sockaddr?) {
            static SOCKET_ERROR := -1
            if this._sock = -1
                this.CreateSock()
            if !IsSet(sockaddr)
                sockaddr := this.Createsockaddr(host, port)
            result := DllCall("ws2_32\bind",
                "ptr", this._sock,    ; [in] SOCKET s
                "ptr", sockaddr.Ptr,  ; [in] const sockaddr *name
                "int", sockaddr.Size, ; [in] int namelen
                "int")                ; int WSAAPI
            if result = SOCKET_ERROR
                throw this.WSAError()
        }

        Listen(backlog := 10) {
            static SOCKET_ERROR := -1
            result := DllCall("ws2_32\listen",
                "ptr", this._sock, ; [in] SOCKET s
                "int", backlog,    ; [in] int    backlog
                "int")             ; int WSAAPI
            if result = SOCKET_ERROR
                throw this.WSAError()
        }

        Accept() {
            static INVALID_SOCKET := A_PtrSize = 8 ? 0xffffffffffffffff : 0xffffffff, NULL := 0
            sock := DllCall("ws2_32\accept",
                "ptr", this._sock, ; [in] SOCKET s
                "ptr", NULL,       ; [out] sockaddr *addr
                "ptr", NULL,       ; [in, out] int *addrlen
                "ptr")             ; SOCKET WSAAPI
            if sock = INVALID_SOCKET
                throw this.WSAError()
            return sock
        }
    }
    class Client extends Socket {
        static __New() => 0

        Connect(host, port, sockaddr?) {
            static SOCKET_ERROR := -1
            if this._sock = -1
                this.CreateSock()
            if !IsSet(sockaddr)
                sockaddr := this.Createsockaddr(host, port)
            result := DllCall("ws2_32\connect",
                "ptr", this._sock,    ; [in] SOCKET s
                "ptr", sockaddr.Ptr,  ; [in] const sockaddr *name
                "int", sockaddr.Size, ; [in] int namelen
                "int")                ; int WSAAPI
            if result = SOCKET_ERROR
                throw this.WSAError()
        }

        ReceiveRaw(message_buffer) {
            static SOCKET_ERROR := -1
            size := DllCall("ws2_32\recv",
                "ptr", this._sock,          ; [in] SOCKET s
                "ptr", message_buffer.Ptr,  ; [out] char *buf
                "int", message_buffer.Size, ; [in] int len
                "int", 0,                   ; [in] int flags
                "int")                      ; int
            if size = SOCKET_ERROR
                throw this.WSAError()
            return size
        }

        ReceiveText(buffer_size := 256, encoding := "UTF-8") {
            buf := Buffer(buffer_size)
            length := this.ReceiveRaw(buf)
            return StrGet(buf, length, encoding)
        }

        SendRaw(message_buffer) {
            static SOCKET_ERROR := -1
            result := DllCall("ws2_32\send",
                "ptr", this._sock,          ; [in] SOCKET     s,
                "ptr", message_buffer.Ptr,  ; [in] const char *buf,
                "int", message_buffer.Size, ; [in] int        len,
                "int", 0,                   ; [in] int        flags
                "int")                      ; int WSAAPIs
            if result = SOCKET_ERROR
                throw this.WSAError()
        }

        SendText(message, encoding := "UTF-8") {
            buf := Buffer(StrPut(message, encoding))
            StrPut(message, buf, encoding)
            this.SendRaw(buf)
        }
    }
}
