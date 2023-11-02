# 导入所需的模块
import socket
import requests
from pyquery import PyQuery
import re
import os


def download_html(socket:socket.socket, bufsize=10240):
    # 构造HTTP的GET请求，获取网页的内容
    request = "GET / HTTP/1.1\r\nHost: {}\r\n\n".format(url)
    socket.send(request.encode())

    # get html content
    with open("people.txt", "wb") as f:
        while(True):
            response = socket.recv(bufsize)
            if len(response):
                f.write(response)
            else:
                break
            
    # 关闭socket连接
    s.close()

def download_img(images:list):
    # 遍历图片链接列表，下载图片并保存到本地，假设保存在images文件夹中
    for i, image in enumerate(images):
        # 使用requests模块获取图片的二进制数据
        data = requests.get(image).content
        # 构造图片的文件名，使用序号和原始链接的后缀
        filename = "images/" + str(i) + image[-4:]
        # 打开一个文件对象，以二进制写入模式
        with open(filename, "wb") as f:
            # 将图片数据写入到文件中
            f.write(data)
        
def get_img_list(file_name="people.txt"):
    images = []
    with open(file_name, "r") as f:
        txt_content =  f.read()
        pyQuery_content = PyQuery(txt_content)
        print(pyQuery_content.text()[:100])
        for img in pyQuery_content('img').items():
            img_url = 'http://www.people.com.cn'+img.attr("src")
            images.append(img_url)
    return images    


if __name__ == "__main__":
        
    # 定义目标网址和端口号
    url = "www.people.com.cn"
    port = 80

    # 创建一个socket对象，使用TCP协议
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # 连接到目标网址和端口号
    s.connect((url, port))

    # 下载html内容
    # download_html(s)

    # 从保存的html文本文件中得到所有的img.attr.url
    img_list = get_img_list("people.txt")

    # 下载图片
    download_img(img_list)




