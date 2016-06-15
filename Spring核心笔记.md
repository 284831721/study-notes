- AnnotationMethodHandlerAdapter.java  处理controller类里方法上的各种注解,@PathVariable @RequestBody @Cookie等 
- ServletContextListener.contextInitialized()该方法会在所有filter servlet初始化之前执行
- AbstractRefreshableWebApplicationContext
- XmlWebApplicationContext
- Default6SingletonBeanRegistry 管理所有单例bean
- RequestResponseBodyMethodProcessor 处理ResponseBody返回内容格式的类
- 关于内容协商:
What we did, in both cases:

> Disabled path extension. Note that favor does not mean use one approach in preference to another, it just enables or disables it. The order of checking is always path extension, parameter, Accept header.
Enable the use of the URL parameter but instead of using the default parameter, format, we will use mediaType instead.
Ignore the Accept header completely. This is often the best approach if most of your clients are actually web-browsers (typically making REST calls via AJAX).
Don't use the JAF, instead specify the media type mappings manually - we only wish to support JSON and XML.

- 先看pathExt,其次是parameter(类似format),最后是Accept header
- 如果都没有,则先按 q
```java
protected int compareParameters(MediaType mediaType1, MediaType mediaType2) {
   double quality1 = mediaType1.getQualityValue();
   double quality2 = mediaType2.getQualityValue();
   int qualityComparison = Double.compare(quality2, quality1);
   if (qualityComparison != 0) {
      return qualityComparison;  // audio/*;q=0.7 < audio/*;q=0.3
   }
   return super.compareParameters(mediaType1, mediaType2);
}
```
- 如果没有Quality则按MimeType中的默认排序规则
```java
 public int compare(MediaType mediaType1, MediaType mediaType2) {
            double quality1 = mediaType1.getQualityValue();
            double quality2 = mediaType2.getQualityValue();
            int qualityComparison = Double.compare(quality2, quality1);
            if (qualityComparison != 0) {
                return qualityComparison;  // audio/*;q=0.7 < audio/*;q=0.3
            } else if (mediaType1.isWildcardType() && !mediaType2.isWildcardType()) { // */* < audio/*
                return 1;
            } else if (mediaType2.isWildcardType() && !mediaType1.isWildcardType()) { // audio/* > */*
                return -1;
            } else if (!mediaType1.getType().equals(mediaType2.getType())) { // audio/basic == text/html
                return 0;
            } else { // mediaType1.getType().equals(mediaType2.getType())
                if (mediaType1.isWildcardSubtype() && !mediaType2.isWildcardSubtype()) { // audio/* < audio/basic
                    return 1;
                } else if (mediaType2.isWildcardSubtype() && !mediaType1.isWildcardSubtype()) { // audio/basic > audio/*
                    return -1;
                } else if (!mediaType1.getSubtype().equals(mediaType2.getSubtype())) { // audio/basic == audio/wave
                    return 0;
                } else {
                    int paramsSize1 = mediaType1.getParameters().size();
                    int paramsSize2 = mediaType2.getParameters().size();
                    return (paramsSize2 < paramsSize1 ?
                            -1 :
                            (paramsSize2 == paramsSize1 ? 0 : 1)); // audio/basic;level=1 < audio/basic
                }
            }
        }
```

- HandlerMapping　负责将请求映射到Controller中的方法
具体有　RequestMappingHandlerMapping　和　BeanNameUrlHandlerMapping

- HandlerAdapter 负责Controller中方法的处理
常用的实现有
>RequestMappingHandlerAdapter　processing requests with annotated controller methods
HttpRequestHandlerAdapter　　processing requests with {@link HttpRequestHandler}
SimpleControllerHandlerAdapter　processing requests with interface-based {@link Controller}s

- HandlerExceptionResolver　负责异常处理
常用的实现有
>ExceptionHandlerExceptionResolver　处理用@ExceptionHandler注解的方法
ResponseStatusExceptionResolver　处理@ResponseStatus注解的方法
DefaultHandlerExceptionResolver 处理已知的各种Spring异常

- RequestMappingHandlerAdapter　和　RequestMappingHandlerAdapter　都用到
> ContentNegotiationManager内容协商管理器
DefaultFormattingConversionService格式转换器
LocalValidatorFactoryBean　合法验证器