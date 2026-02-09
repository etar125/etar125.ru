# Фиксим сглаживание в Java Swing приложениях
### 12.10.2025

Захотел поиграть в infdev и alpha Minecraft, и скачал себе Betacraft.  
Запускаю, а тут такая картина:  

!![Несглаженный текст](https://etar125.ru/media/bcb_1210.jpg)

Решается всё очень просто: добавьте к параметрам запуска (перед -jar) `-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true`.  
Чтобы постоянно это не прописывать, добавьте в свой `.bashrc`:
```
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"
```

Результат:  

!![Сглаженный текст](https://etar125.ru/media/bca_1210.jpg)
