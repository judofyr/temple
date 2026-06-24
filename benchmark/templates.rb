# frozen_string_literal: true
#
# Realistic ERB templates for benchmarking Temple's compilation pipeline.
#
module BenchmarkTemplates
  # A simple blog post page (~50 lines)
  BLOG_POST = <<~'ERB'
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <title><%= @post.title %> - My Blog</title>
      <link rel="stylesheet" href="/css/style.css">
    </head>
    <body>
      <header>
        <nav>
          <a href="/">Home</a>
          <a href="/archive">Archive</a>
          <a href="/about">About</a>
        </nav>
      </header>
      <main>
        <article>
          <h1><%= @post.title %></h1>
          <div class="meta">
            <time datetime="<%= @post.date.iso8601 %>"><%= @post.date.strftime("%B %d, %Y") %></time>
            <span class="author">by <%= @post.author %></span>
          </div>
          <div class="content">
            <%= @post.body %>
          </div>
          <% if @post.tags.any? %>
            <div class="tags">
              <% @post.tags.each do |tag| %>
                <a href="/tags/<%= tag %>" class="tag"><%= tag %></a>
              <% end %>
            </div>
          <% end %>
        </article>
        <section class="comments">
          <h2>Comments (<%= @comments.size %>)</h2>
          <% @comments.each do |comment| %>
            <div class="comment" id="comment-<%= comment.id %>">
              <strong><%= comment.author %></strong>
              <time><%= comment.created_at %></time>
              <p><%= comment.body %></p>
            </div>
          <% end %>
        </section>
      </main>
      <footer>
        <p>&copy; 2024 My Blog. All rights reserved.</p>
      </footer>
    </body>
    </html>
  ERB

  # An e-commerce product listing page (~100 lines)
  PRODUCT_LISTING = <<~'ERB'
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title><%= @category.name %> - Shop</title>
      <meta name="description" content="<%= @category.description %>">
      <link rel="stylesheet" href="/css/shop.css">
      <script src="/js/shop.js" defer></script>
    </head>
    <body>
      <header>
        <div class="logo"><a href="/">ShopName</a></div>
        <nav class="main-nav">
          <% @categories.each do |cat| %>
            <a href="/category/<%= cat.slug %>" class="<%= 'active' if cat == @category %>"><%= cat.name %></a>
          <% end %>
        </nav>
        <div class="cart-icon">
          <a href="/cart">Cart (<%= @cart_count %>)</a>
        </div>
      </header>
      <div class="breadcrumbs">
        <a href="/">Home</a> &raquo;
        <% @category.ancestors.each do |ancestor| %>
          <a href="/category/<%= ancestor.slug %>"><%= ancestor.name %></a> &raquo;
        <% end %>
        <span><%= @category.name %></span>
      </div>
      <main>
        <aside class="filters">
          <h3>Filters</h3>
          <% @filters.each do |filter| %>
            <div class="filter-group">
              <h4><%= filter.name %></h4>
              <% filter.options.each do |option| %>
                <label>
                  <input type="checkbox" name="filter[<%= filter.key %>][]" value="<%= option.value %>"
                         <%= 'checked' if @active_filters.include?(option.value) %>>
                  <%= option.label %> (<%= option.count %>)
                </label>
              <% end %>
            </div>
          <% end %>
        </aside>
        <div class="products">
          <div class="sort-bar">
            <span><%= @total_count %> products</span>
            <select name="sort">
              <option value="relevance" <%= 'selected' if @sort == 'relevance' %>>Relevance</option>
              <option value="price_asc" <%= 'selected' if @sort == 'price_asc' %>>Price: Low to High</option>
              <option value="price_desc" <%= 'selected' if @sort == 'price_desc' %>>Price: High to Low</option>
              <option value="newest" <%= 'selected' if @sort == 'newest' %>>Newest</option>
            </select>
          </div>
          <div class="product-grid">
            <% @products.each do |product| %>
              <div class="product-card" data-id="<%= product.id %>">
                <a href="/product/<%= product.slug %>">
                  <img src="<%= product.image_url %>" alt="<%= product.name %>" loading="lazy">
                </a>
                <div class="product-info">
                  <h3><a href="/product/<%= product.slug %>"><%= product.name %></a></h3>
                  <div class="price">
                    <% if product.on_sale? %>
                      <span class="original-price">$<%= product.original_price %></span>
                      <span class="sale-price">$<%= product.sale_price %></span>
                    <% else %>
                      <span class="price">$<%= product.price %></span>
                    <% end %>
                  </div>
                  <div class="rating">
                    <% product.rating.to_i.times do %>
                      <span class="star filled">&#9733;</span>
                    <% end %>
                    <% (5 - product.rating.to_i).times do %>
                      <span class="star">&#9734;</span>
                    <% end %>
                    <span class="count">(<%= product.review_count %>)</span>
                  </div>
                  <% if product.in_stock? %>
                    <button class="add-to-cart" data-product-id="<%= product.id %>">Add to Cart</button>
                  <% else %>
                    <button class="out-of-stock" disabled>Out of Stock</button>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
          <div class="pagination">
            <% if @page > 1 %>
              <a href="?page=<%= @page - 1 %>">&laquo; Prev</a>
            <% end %>
            <% @total_pages.times do |i| %>
              <a href="?page=<%= i + 1 %>" class="<%= 'active' if i + 1 == @page %>"><%= i + 1 %></a>
            <% end %>
            <% if @page < @total_pages %>
              <a href="?page=<%= @page + 1 %>">Next &raquo;</a>
            <% end %>
          </div>
        </div>
      </main>
      <footer>
        <div class="footer-links">
          <div class="col">
            <h4>Customer Service</h4>
            <a href="/help">Help Center</a>
            <a href="/returns">Returns</a>
            <a href="/shipping">Shipping Info</a>
          </div>
          <div class="col">
            <h4>About Us</h4>
            <a href="/about">Our Story</a>
            <a href="/careers">Careers</a>
            <a href="/press">Press</a>
          </div>
        </div>
        <p>&copy; 2024 ShopName Inc.</p>
      </footer>
    </body>
    </html>
  ERB

  # A dashboard with tables (~120 lines)
  ADMIN_DASHBOARD = <<~'ERB'
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <title>Admin Dashboard</title>
      <link rel="stylesheet" href="/css/admin.css">
    </head>
    <body>
      <nav class="sidebar">
        <div class="brand">Admin Panel</div>
        <ul>
          <% @nav_items.each do |item| %>
            <li class="<%= 'active' if item.path == @current_path %>">
              <a href="<%= item.path %>">
                <span class="icon"><%= item.icon %></span>
                <span class="label"><%= item.label %></span>
                <% if item.badge_count && item.badge_count > 0 %>
                  <span class="badge"><%= item.badge_count %></span>
                <% end %>
              </a>
            </li>
          <% end %>
        </ul>
      </nav>
      <main class="content">
        <header class="topbar">
          <h1><%= @page_title %></h1>
          <div class="user-menu">
            <span><%= @current_user.name %></span>
            <a href="/logout">Logout</a>
          </div>
        </header>
        <div class="stats-row">
          <% @stats.each do |stat| %>
            <div class="stat-card">
              <div class="stat-value"><%= stat.value %></div>
              <div class="stat-label"><%= stat.label %></div>
              <div class="stat-change <%= stat.change >= 0 ? 'positive' : 'negative' %>">
                <%= stat.change >= 0 ? '+' : '' %><%= stat.change %>%
              </div>
            </div>
          <% end %>
        </div>
        <div class="card">
          <div class="card-header">
            <h2>Recent Orders</h2>
            <div class="card-actions">
              <input type="text" placeholder="Search orders..." value="<%= @search_query %>">
              <select name="status">
                <option value="">All Statuses</option>
                <% @statuses.each do |status| %>
                  <option value="<%= status %>" <%= 'selected' if @filter_status == status %>><%= status.capitalize %></option>
                <% end %>
              </select>
            </div>
          </div>
          <table class="data-table">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Items</th>
                <th>Total</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <% @orders.each do |order| %>
                <tr class="<%= 'highlighted' if order.flagged? %>">
                  <td><a href="/admin/orders/<%= order.id %>">#<%= order.id %></a></td>
                  <td>
                    <div class="customer-cell">
                      <strong><%= order.customer_name %></strong>
                      <small><%= order.customer_email %></small>
                    </div>
                  </td>
                  <td><%= order.created_at.strftime("%Y-%m-%d %H:%M") %></td>
                  <td><%= order.item_count %> items</td>
                  <td class="amount">$<%= "%.2f" % order.total %></td>
                  <td>
                    <span class="status-badge status-<%= order.status %>"><%= order.status %></span>
                  </td>
                  <td>
                    <div class="action-buttons">
                      <a href="/admin/orders/<%= order.id %>" class="btn btn-sm">View</a>
                      <% if order.status == 'pending' %>
                        <a href="/admin/orders/<%= order.id %>/approve" class="btn btn-sm btn-primary">Approve</a>
                      <% end %>
                      <% if order.status != 'shipped' && order.status != 'cancelled' %>
                        <a href="/admin/orders/<%= order.id %>/cancel" class="btn btn-sm btn-danger">Cancel</a>
                      <% end %>
                    </div>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
          <div class="table-footer">
            <span>Showing <%= @orders.size %> of <%= @total_orders %> orders</span>
            <div class="pagination">
              <% @total_pages.times do |i| %>
                <a href="?page=<%= i + 1 %>" class="<%= 'active' if i + 1 == @page %>"><%= i + 1 %></a>
              <% end %>
            </div>
          </div>
        </div>
        <div class="card">
          <div class="card-header">
            <h2>Activity Log</h2>
          </div>
          <ul class="activity-list">
            <% @activities.each do |activity| %>
              <li>
                <span class="activity-icon"><%= activity.icon %></span>
                <div class="activity-content">
                  <strong><%= activity.user %></strong> <%= activity.description %>
                  <time><%= activity.time_ago %> ago</time>
                </div>
              </li>
            <% end %>
          </ul>
        </div>
      </main>
    </body>
    </html>
  ERB

  # A simple, mostly-static marketing page (stress tests static merging)
  LANDING_PAGE = <<~'ERB'
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Welcome to Our Platform</title>
      <meta name="description" content="The best platform for building amazing things.">
      <link rel="stylesheet" href="/css/landing.css">
    </head>
    <body>
      <header class="hero">
        <nav>
          <div class="logo">Platform</div>
          <ul>
            <li><a href="#features">Features</a></li>
            <li><a href="#pricing">Pricing</a></li>
            <li><a href="#testimonials">Testimonials</a></li>
            <li><a href="/login" class="btn">Log In</a></li>
          </ul>
        </nav>
        <div class="hero-content">
          <h1>Build Something Amazing</h1>
          <p>Our platform gives you all the tools you need to create, deploy, and scale your applications with ease.</p>
          <a href="/signup" class="btn btn-primary btn-lg">Get Started Free</a>
        </div>
      </header>
      <section id="features" class="features">
        <h2>Why Choose Us?</h2>
        <div class="feature-grid">
          <div class="feature">
            <div class="icon">&#9889;</div>
            <h3>Lightning Fast</h3>
            <p>Our infrastructure is optimized for speed. Your applications will load in milliseconds, not seconds.</p>
          </div>
          <div class="feature">
            <div class="icon">&#128274;</div>
            <h3>Secure by Default</h3>
            <p>Enterprise-grade security built into every layer. SOC2 compliant, encrypted at rest and in transit.</p>
          </div>
          <div class="feature">
            <div class="icon">&#128200;</div>
            <h3>Scales Automatically</h3>
            <p>From zero to millions of users. Our auto-scaling infrastructure grows with your business.</p>
          </div>
          <div class="feature">
            <div class="icon">&#129309;</div>
            <h3>Great Support</h3>
            <p>Our team is available 24/7 to help you succeed. Average response time under 5 minutes.</p>
          </div>
        </div>
      </section>
      <section id="pricing" class="pricing">
        <h2>Simple Pricing</h2>
        <div class="pricing-grid">
          <% @plans.each do |plan| %>
            <div class="plan-card <%= 'featured' if plan.featured? %>">
              <h3><%= plan.name %></h3>
              <div class="price">$<%= plan.price %><span>/mo</span></div>
              <ul>
                <% plan.features.each do |feature| %>
                  <li><%= feature %></li>
                <% end %>
              </ul>
              <a href="/signup?plan=<%= plan.slug %>" class="btn"><%= plan.featured? ? 'Start Free Trial' : 'Get Started' %></a>
            </div>
          <% end %>
        </div>
      </section>
      <section id="testimonials" class="testimonials">
        <h2>What Our Customers Say</h2>
        <div class="testimonial-grid">
          <% @testimonials.each do |t| %>
            <div class="testimonial">
              <blockquote><%= t.quote %></blockquote>
              <div class="author">
                <img src="<%= t.avatar_url %>" alt="<%= t.name %>">
                <div>
                  <strong><%= t.name %></strong>
                  <span><%= t.title %>, <%= t.company %></span>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </section>
      <footer>
        <div class="footer-grid">
          <div class="col">
            <h4>Product</h4>
            <a href="/features">Features</a>
            <a href="/pricing">Pricing</a>
            <a href="/docs">Documentation</a>
            <a href="/changelog">Changelog</a>
          </div>
          <div class="col">
            <h4>Company</h4>
            <a href="/about">About</a>
            <a href="/blog">Blog</a>
            <a href="/careers">Careers</a>
            <a href="/contact">Contact</a>
          </div>
          <div class="col">
            <h4>Legal</h4>
            <a href="/privacy">Privacy Policy</a>
            <a href="/terms">Terms of Service</a>
            <a href="/security">Security</a>
          </div>
        </div>
        <p class="copyright">&copy; 2024 Platform Inc. All rights reserved.</p>
      </footer>
    </body>
    </html>
  ERB

  # Email template - lots of inline styles, deeply nested tables (HTML email pattern)
  EMAIL_TEMPLATE = <<~'ERB'
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width">
      <title>Order Confirmation</title>
    </head>
    <body style="margin: 0; padding: 0; background-color: #f4f4f4; font-family: Arial, sans-serif;">
      <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f4f4f4;">
        <tr>
          <td align="center" style="padding: 20px 0;">
            <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px;">
              <tr>
                <td style="padding: 40px 30px; text-align: center; background-color: #2563eb; border-radius: 8px 8px 0 0;">
                  <h1 style="color: #ffffff; margin: 0; font-size: 28px;">Order Confirmed!</h1>
                  <p style="color: #dbeafe; margin: 10px 0 0;">Order #<%= @order.number %></p>
                </td>
              </tr>
              <tr>
                <td style="padding: 30px;">
                  <p style="margin: 0 0 20px;">Hi <%= @customer.first_name %>,</p>
                  <p style="margin: 0 0 20px;">Thank you for your order! Here's a summary of what you purchased:</p>
                  <table width="100%" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
                    <tr style="background-color: #f8fafc;">
                      <th style="padding: 12px; text-align: left; border-bottom: 2px solid #e2e8f0;">Item</th>
                      <th style="padding: 12px; text-align: center; border-bottom: 2px solid #e2e8f0;">Qty</th>
                      <th style="padding: 12px; text-align: right; border-bottom: 2px solid #e2e8f0;">Price</th>
                    </tr>
                    <% @order.items.each do |item| %>
                      <tr>
                        <td style="padding: 12px; border-bottom: 1px solid #e2e8f0;">
                          <strong><%= item.name %></strong>
                          <% if item.variant %>
                            <br><span style="color: #64748b; font-size: 13px;"><%= item.variant %></span>
                          <% end %>
                        </td>
                        <td style="padding: 12px; text-align: center; border-bottom: 1px solid #e2e8f0;"><%= item.quantity %></td>
                        <td style="padding: 12px; text-align: right; border-bottom: 1px solid #e2e8f0;">$<%= "%.2f" % item.total %></td>
                      </tr>
                    <% end %>
                    <tr>
                      <td colspan="2" style="padding: 12px; text-align: right;">Subtotal</td>
                      <td style="padding: 12px; text-align: right;">$<%= "%.2f" % @order.subtotal %></td>
                    </tr>
                    <% if @order.discount > 0 %>
                      <tr>
                        <td colspan="2" style="padding: 12px; text-align: right; color: #16a34a;">Discount (<%= @order.discount_code %>)</td>
                        <td style="padding: 12px; text-align: right; color: #16a34a;">-$<%= "%.2f" % @order.discount %></td>
                      </tr>
                    <% end %>
                    <tr>
                      <td colspan="2" style="padding: 12px; text-align: right;">Shipping</td>
                      <td style="padding: 12px; text-align: right;"><%= @order.shipping_cost > 0 ? "$#{"%.2f" % @order.shipping_cost}" : "Free" %></td>
                    </tr>
                    <tr>
                      <td colspan="2" style="padding: 12px; text-align: right; font-weight: bold; font-size: 16px;">Total</td>
                      <td style="padding: 12px; text-align: right; font-weight: bold; font-size: 16px;">$<%= "%.2f" % @order.total %></td>
                    </tr>
                  </table>
                </td>
              </tr>
              <tr>
                <td style="padding: 0 30px 30px;">
                  <h2 style="font-size: 18px; margin: 0 0 15px;">Shipping Address</h2>
                  <div style="background-color: #f8fafc; padding: 15px; border-radius: 6px;">
                    <p style="margin: 0;">
                      <%= @shipping.name %><br>
                      <%= @shipping.street %><br>
                      <% if @shipping.street2 %>
                        <%= @shipping.street2 %><br>
                      <% end %>
                      <%= @shipping.city %>, <%= @shipping.state %> <%= @shipping.zip %><br>
                      <%= @shipping.country %>
                    </p>
                  </div>
                </td>
              </tr>
              <tr>
                <td style="padding: 0 30px 30px; text-align: center;">
                  <a href="<%= @tracking_url %>" style="display: inline-block; padding: 14px 28px; background-color: #2563eb; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: bold;">Track Your Order</a>
                </td>
              </tr>
              <tr>
                <td style="padding: 20px 30px; text-align: center; background-color: #f8fafc; border-radius: 0 0 8px 8px; color: #64748b; font-size: 13px;">
                  <p style="margin: 0 0 10px;">Questions? Contact us at <a href="mailto:<%= @support_email %>" style="color: #2563eb;"><%= @support_email %></a></p>
                  <p style="margin: 0;"><a href="<%= @unsubscribe_url %>" style="color: #94a3b8;">Unsubscribe</a></p>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
  ERB

  ALL = {
    'blog_post'       => BLOG_POST,
    'product_listing' => PRODUCT_LISTING,
    'admin_dashboard' => ADMIN_DASHBOARD,
    'landing_page'    => LANDING_PAGE,
    'email_template'  => EMAIL_TEMPLATE,
  }.freeze
end
