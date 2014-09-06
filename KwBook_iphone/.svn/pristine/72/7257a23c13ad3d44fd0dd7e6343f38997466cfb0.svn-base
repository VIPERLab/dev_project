//
//  Variant.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-5.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_Variant_h
#define KwSing_Variant_h


#include <string>
#include <typeinfo>
#include "ToString.h"
#include "ToDouble.h"

namespace KwTools
{
        
    class Variant
    {
    public: 
        Variant()
        : content(0)
        {
        }
        
        template<typename ValueType>
        Variant(const ValueType & value)
        : content(new holder<ValueType>(value))
        {
        }
        
        Variant(const char* value)
        : content(new holder<std::string>(value))
        {
        }
        
        Variant(NSString* value)
        : content(new holder<std::string>([value UTF8String]))
        {
        }
        
        Variant(const Variant & other)
        : content(other.content ? other.content->clone() : 0)
        {
        }
        
        ~Variant()
        {
            delete content;
            content = NULL;
        }
        
    public: 
        Variant & swap(Variant & rhs)
        {
            std::swap(content, rhs.content);
            return *this;
        }
        
        template<typename ValueType>
        Variant & operator=(const ValueType & rhs)
        {
            Variant(rhs).swap(*this);
            return *this;
        }
        
        Variant & operator=(const Variant & rhs)
        {
            Variant(rhs).swap(*this);
            return *this;
        }
        
        operator std::string() const
        {
            assert(content);
            
            return content ? content->ToString() : "";
        }
        
        operator NSString*()const
        {
            assert(content);

            return content?[NSString stringWithUTF8String:content->ToString().c_str()]:[NSString string];
        }
        
        operator double() const 
        {
            assert(content);
            
            return content ? content->ToDouble() : throw std::exception();
        }
            
        operator float() const
        {
            return content ? content->ToDouble() : throw std::exception();
        }
        
//        template<typename T>
//        operator T*() const
//        {
//            assert(content);
//            
//            return content ? static_cast<T*>(content->ToObject()) : NULL;
//        }
        
        template<typename T>
        operator T() const
        {
            assert(content);
            
            T* pVal = content ? static_cast<T*>(content->ToObject()) : NULL;
            return pVal ? *pVal : T();
        }
        
    public: // queries
        bool empty() const
        {
            return !content;
        }
        
        const std::type_info & type() const
        {
            return content ? content->type() : typeid(void);
        }
        
    private:
        class placeholder
        {
        public: // structors
            virtual ~placeholder()
            {
            }
            
        public: // queries
            virtual const std::type_info & type() const = 0;
            virtual placeholder * clone() const = 0;
            virtual std::string ToString()const = 0;
            virtual double ToDouble() const = 0;
            virtual void* ToObject() const = 0;
        };
        
        template<typename ValueType>
        class holder : public placeholder
        {
        public: // structors
            holder(const ValueType & value)
            : held(value)
            {
            }
            
        public: // queries
            virtual const std::type_info & type() const
            {
                return typeid(ValueType);
            }
            virtual placeholder * clone() const
            {
                return new holder(held);
            }
            virtual std::string ToString()const
            {
                return KwTools::Convert::ConvertToString(held);
            }
            virtual double ToDouble() const
            {
                return KwTools::Convert::ConvertToDouble(held);
            }
            virtual void* ToObject() const
            {
                return (void*)&held;
            }
            
        public: 
            ValueType held;
        };
        
        template<typename ValueType>
        class holder<ValueType*> : public placeholder
        {
        public: 
            holder(const ValueType* const value)
            : held(const_cast<ValueType*>(value))
            {
            }
            
        public:
            virtual const std::type_info & type() const
            {
                return typeid(ValueType);
            }
            virtual placeholder * clone() const
            {
                return new holder(held);
            }
            virtual std::string ToString()const
            {
                return KwTools::Convert::ConvertToString(*held);
            }
            virtual double ToDouble() const
            {
                return KwTools::Convert::ConvertToDouble(*held);
            }
            virtual void* ToObject() const
            {
                return (__bridge void*)held;
            }
        public: 
            ValueType* held;
        };
        
    private:
        placeholder * content;
    };
        
}//namespace KwTools

#endif
